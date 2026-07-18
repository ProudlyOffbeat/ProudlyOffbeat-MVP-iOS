//
//  OnboardingFlowViewModel.swift
//  LivingStory-iOS
//
//  온보딩 세팅 플로우의 상태/전이/병합/저장 담당.
//  - HomeKit 트리(실시간) + DB config(저장값) 병합
//  - phase(OnboardingPhase) 하나로 화면 분기
//

import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class OnboardingFlowViewModel {

    // MARK: - State
    private(set) var phase: OnboardingPhase = .requestingPermission
    private(set) var homes: [HomeModel] = []

    // MARK: - User Selections
    var selectedHomeID: UUID?
    var enabledLightIDs: Set<UUID> = []
    var enabledSpeakerIDs: Set<UUID> = []
    var childAge: Int = 7
    var readingTime: Date = OnboardingFlowViewModel.defaultReadingTime

    /// 완료 시 코디네이터 통지
    var onCompleted: (() -> Void)?

    /// 사용자가 단계를 한 번이라도 진행했는지 (HomeKit homes 지연 로드 시 시작단계 재동기화 제어)
    private var userDidAdvance = false

    /// 거부 신호 디바운스 (권한 OK인데 순간 거부가 떠서 #27이 깜빡이는 것 방지)
    private var deniedTask: Task<Void, Never>?

    // MARK: - Dependencies
    private let homeKit = HomeKitManager()
    private let repository: EnvironmentSettingRepositoryProtocol

    init(repository: EnvironmentSettingRepositoryProtocol? = nil) {
        // @MainActor 타입이라 기본 인자가 아닌 init 본문(@MainActor)에서 생성
        self.repository = repository ?? EnvironmentSettingRepository()
        bindHomeKit()
    }

    // MARK: - Derived

    var selectedHome: HomeModel? { homes.first { $0.id == selectedHomeID } }

    /// 집 1개면 .home 단계 스킵
    var activeSteps: [SetupStep] {
        homes.count <= 1 ? SetupStep.allCases.filter { $0 != .home } : SetupStep.allCases
    }

    var currentStep: SetupStep? {
        if case .setup(let step) = phase { return step }
        return nil
    }

    /// 진행도 (현재, 전체)
    var progress: (current: Int, total: Int) {
        guard let step = currentStep, let idx = activeSteps.firstIndex(of: step) else {
            return (0, activeSteps.count)
        }
        return (idx + 1, activeSteps.count)
    }

    func lightRooms() -> [RoomModel] { rooms(of: .light) }
    func speakerRooms() -> [RoomModel] { rooms(of: .speaker) }

    // MARK: - Intents

    func next() {
        guard let step = currentStep, let idx = activeSteps.firstIndex(of: step) else { return }
        userDidAdvance = true
        if idx + 1 < activeSteps.count {
            phase = .setup(activeSteps[idx + 1])
        } else {
            complete()
        }
    }

    func back() {
        guard let step = currentStep, let idx = activeSteps.firstIndex(of: step), idx > 0 else { return }
        phase = .setup(activeSteps[idx - 1])
    }

    func skip() { complete() }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func selectHome(_ id: UUID) {
        selectedHomeID = id
        loadSavedConfig(homeID: id)
    }

    func toggleLight(_ id: UUID) { toggle(id, in: &enabledLightIDs) }
    func toggleSpeaker(_ id: UUID) { toggle(id, in: &enabledSpeakerIDs) }

    // MARK: - Private: rooms

    private func rooms(of kind: HomeDeviceType) -> [RoomModel] {
        (selectedHome?.rooms ?? []).compactMap { room in
            let devices = room.devices.filter { $0.deviceType == kind }
            guard !devices.isEmpty else { return nil }
            var copy = room
            copy.devices = devices
            return copy
        }
    }

    private func toggle(_ id: UUID, in set: inout Set<UUID>) {
        if set.contains(id) { set.remove(id) } else { set.insert(id) }
    }

    // MARK: - Private: persistence

    private func loadSavedConfig(homeID: UUID) {
        guard let saved = try? repository.fetch(homeID: homeID) else { return }
        enabledLightIDs = saved.enabledDeviceIDs(of: .light)
        enabledSpeakerIDs = saved.enabledDeviceIDs(of: .speaker)
        childAge = saved.childAge
        readingTime = Calendar.current.date(
            bySettingHour: saved.readingHour, minute: saved.readingMinute, second: 0, of: Date()
        ) ?? readingTime
    }

    private func complete() {
        // 선택한 집이 있으면 config 저장 (없으면 저장할 게 없으므로 그대로 완료)
        var didPersist = true
        if let homeID = selectedHomeID ?? homes.first?.id {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: readingTime)
            let profile = EnvironmentSettingProfile(
                homeID: homeID,
                childAge: childAge,
                readingHour: comps.hour ?? 20,
                readingMinute: comps.minute ?? 0,
                deviceConfigs: buildConfigs()
            )
            do {
                try repository.save(profile)
            } catch {
                // 저장 실패(디스크 부족·검증 등)를 삼키지 않고 로깅.
                didPersist = false
                print("[Onboarding] 환경 세팅 저장 실패: \(error.localizedDescription)")
            }
        }
        // 읽어줄 시간을 단일 소스(UserData)에도 동기화 → 알림 스케줄 기준 통일 (온보딩 CoreData ↔ 설정 UserDefaults)
        UserData.notificationTime = readingTime
        UserData.notificationEnabled = true

        // 저장이 성공했거나 저장할 게 없을 때만 완료 도장 → 실패 시 다음 진입에서 재세팅 기회 유지.
        if didPersist {
            UserData.hasCompletedInitialSetup = true
        }

        // 알림 권한을 "먼저" 요청하고(사용자 응답 대기) → 그 다음 완료 화면 애니메이션. (동시 표시 방지)
        Task { [weak self] in
            await ReadingNotificationScheduler.shared.requestAuthorization()
            self?.phase = .completed
            try? await Task.sleep(for: .seconds(1.8))
            self?.onCompleted?()
        }
    }

    /// 선택된 집의 모든 기기를 config로 (현재 HomeKit에 존재하는 것만 = 사라진 기기 자연 제외)
    private func buildConfigs() -> [DeviceConfig] {
        var result: [DeviceConfig] = []
        for room in (selectedHome?.rooms ?? []) {
            for device in room.devices {
                let enabled: Bool = switch device.deviceType {
                case .light:   enabledLightIDs.contains(device.id)
                case .speaker: enabledSpeakerIDs.contains(device.id)
                }
                result.append(
                    DeviceConfig(deviceID: device.id, roomID: room.id, kind: device.deviceType, isEnabled: enabled)
                )
            }
        }
        return result
    }

    // MARK: - Private: HomeKit binding

    private func bindHomeKit() {
        homeKit.onPermissionDenied = { [weak self] in
            self?.scheduleDeniedIfNeeded()
        }
        homeKit.onHomesUpdated = { [weak self] homes in
            self?.handleHomes(homes)
        }
        homeKit.checkInitialStatus()
    }

    /// 거부 신호를 400ms 디바운스 — 그 안에 homes가 오면(권한 OK) #27을 띄우지 않는다.
    private func scheduleDeniedIfNeeded() {
        if case .setup = phase { return }
        if case .completed = phase { return }
        deniedTask?.cancel()
        deniedTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard let self, !Task.isCancelled else { return }
            if case .setup = self.phase { return }
            if case .completed = self.phase { return }
            self.phase = .permissionDenied
        }
    }

    private func handleHomes(_ homes: [HomeModel]) {
        deniedTask?.cancel()        // homes 도착 = 권한 OK → 대기 중인 거부 취소
        self.homes = homes
        if selectedHomeID == nil, homes.count == 1 {
            selectHome(homes[0].id)
        }
        // 아직 사용자가 단계를 진행하지 않았으면, 최신 homes 기준 시작 단계로 (재)동기화.
        // → 권한 대기/거부 후 진입, HomeKit이 빈 homes 먼저 주고 나중에 로드하는 케이스 모두 대응.
        guard !userDidAdvance else { return }
        if case .completed = phase { return }
        phase = .setup(activeSteps.first ?? .home)
    }

    private static var defaultReadingTime: Date {
        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }
}
