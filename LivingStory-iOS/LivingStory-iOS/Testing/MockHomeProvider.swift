//
//  MockHomeProvider.swift
//  LivingStory-iOS
//
//  HomeKit 없이 UI를 구동하는 가짜 프로바이더 (DEBUG 전용).
//  실제 기기 왕복을 흉내내는 지연을 넣어 옵티미스틱 UI·켜짐 애니메이션을 검증할 수 있다.
//  실제(HomeKitManager)와 동일한 멀티캐스트 계약을 따른다.
//

#if DEBUG
import Foundation

@MainActor
final class MockHomeProvider: HomeDataProviding {

    private enum LastHomeState { case unknown, homes([HomeModel]), denied }
    private var lastState: LastHomeState = .unknown

    private struct Observer {
        weak var owner: AnyObject?
        let onHomes: @MainActor ([HomeModel]) -> Void
        let onDenied: @MainActor () -> Void
    }
    private var observers: [UUID: Observer] = [:]

    private var homes = MockHomeData.makeHomes()

    var currentHomes: [HomeModel] {
        if case .homes(let h) = lastState { return h } else { return [] }
    }

    @discardableResult
    func addObserver(_ owner: AnyObject,
                     onHomesUpdated: @escaping @MainActor ([HomeModel]) -> Void,
                     onPermissionDenied: @escaping @MainActor () -> Void) -> HomeObservation {
        let id = UUID()
        observers[id] = Observer(owner: owner, onHomes: onHomesUpdated, onDenied: onPermissionDenied)
        // 초기 전달을 다음 틱으로 미뤄 호출부 토큰 대입이 먼저 끝나게 함
        Task { @MainActor [weak self] in
            guard let self, self.observers[id] != nil else { return }
            switch self.lastState {
            case .homes(let h): onHomesUpdated(h)
            case .denied: onPermissionDenied()
            case .unknown: self.checkInitialStatus()   // 첫 소비자 보장 (Mock은 항상 허용)
            }
        }
        return HomeObservation { [weak self] in self?.observers[id] = nil }
    }

    /// 권한 허용 흐름 흉내 — 첫 소비자가 안 멈추도록 즉시 홈 방송
    func checkInitialStatus() {
        emitHomes(homes)
    }

    func setPower(_ isOn: Bool, for deviceId: UUID, timeout: TimeInterval) async throws {
        // 실제 기기 왕복 흉내 (옵티미스틱 UI/글로우 애니메이션 확인용)
        try? await Task.sleep(for: .milliseconds(300))
        // 전 구간 MainActor라 락 불필요
        outer: for h in homes.indices {
            for r in homes[h].rooms.indices {
                if let i = homes[h].rooms[r].devices.firstIndex(where: { $0.id == deviceId }) {
                    homes[h].rooms[r].devices[i].isOn = isOn
                    break outer
                }
            }
        }
    }

    func refreshAllCharacteristics() async {
        emitHomes(homes)
    }

    private func emitHomes(_ homes: [HomeModel]) {
        lastState = .homes(homes)
        let snapshot = observers
        var dead: [UUID] = []
        for (id, o) in snapshot {
            if o.owner == nil { dead.append(id) } else { o.onHomes(homes) }
        }
        for id in dead { observers[id] = nil }
    }
}
#endif
