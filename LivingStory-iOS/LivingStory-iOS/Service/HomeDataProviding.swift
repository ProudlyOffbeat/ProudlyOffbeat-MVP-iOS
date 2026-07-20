//
//  HomeDataProviding.swift
//  LivingStory-iOS
//
//  "집/기기 데이터 소스" 추상화. 실제(HomeKitManager)와 목업(MockHomeProvider)을 갈아끼운다.
//  콜백은 단일 클로저가 아니라 addObserver(멀티캐스트)로 받아, 여러 소비처가 하나의 공유
//  인스턴스를 덮어쓰지 않고 각자 구독한다. (앱당 HMHomeManager 1개 — Apple 가이드라인)
//

import Foundation

@MainActor
protocol HomeDataProviding: AnyObject {
    /// 마지막으로 알려진 집 목록 (권한 미결정/거부면 빈 배열). 즉시 동기 조회용.
    var currentHomes: [HomeModel] { get }

    /// 집 목록/권한 변화를 구독. owner를 weak로 잡아 dealloc 시 자동 정리한다.
    /// 등록 직후(다음 틱) 현재 상태를 1회 전달하고, 미결정이면 내부에서 상태 확인을 트리거한다.
    @discardableResult
    func addObserver(
        _ owner: AnyObject,
        onHomesUpdated: @escaping @MainActor ([HomeModel]) -> Void,
        onPermissionDenied: @escaping @MainActor () -> Void
    ) -> HomeObservation

    /// 초기 상태 확인 → 준비되면 구독자에게 방송 (보통 addObserver가 내부에서 호출)
    func checkInitialStatus()
    /// 기기 전원을 목표값으로 설정 (실패/타임아웃 시 throw → 호출부 롤백)
    func setPower(_ isOn: Bool, for deviceId: UUID, timeout: TimeInterval) async throws
    /// 모든 특성 최신값 재동기화
    func refreshAllCharacteristics() async
}

extension HomeDataProviding {
    /// 기본 타임아웃(5초) 편의 오버로드
    func setPower(_ isOn: Bool, for deviceId: UUID) async throws {
        try await setPower(isOn, for: deviceId, timeout: 5)
    }
}

// MARK: - Factory

enum HomeProviderFactory {
    /// 앱 전역에서 딱 1번 호출되어야 함 (AppDelegate.homeProvider가 소유).
    /// DEBUG + 실행 인자 `-UITestMockHome` 또는 환경변수 `MOCK_HOME=1`이면 목업 주입.
    @MainActor
    static func make() -> HomeDataProviding {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        let env = ProcessInfo.processInfo.environment
        if args.contains("-UITestMockHome") || env["MOCK_HOME"] == "1" {
            return MockHomeProvider()
        }
        #endif
        return HomeKitManager()
    }
}
