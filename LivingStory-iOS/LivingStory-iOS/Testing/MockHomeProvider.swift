//
//  MockHomeProvider.swift
//  LivingStory-iOS
//
//  HomeKit 없이 UI를 구동하는 가짜 프로바이더 (DEBUG 전용).
//  실제 기기 왕복을 흉내내는 지연을 넣어 옵티미스틱 UI·켜짐 애니메이션을 검증할 수 있다.
//

#if DEBUG
import Foundation

final class MockHomeProvider: HomeDataProviding, @unchecked Sendable {

    var onHomesUpdated: (@MainActor ([HomeModel]) -> Void)?
    var onPermissionDenied: (@MainActor () -> Void)?

    private let lock = NSLock()
    private var homes = MockHomeData.makeHomes()

    func checkInitialStatus() {
        emit()
    }

    func setPower(_ isOn: Bool, for deviceId: UUID, timeout: TimeInterval) async throws {
        // 실제 기기 왕복 흉내 (옵티미스틱 UI/글로우 애니메이션 확인용)
        try? await Task.sleep(for: .milliseconds(300))
        // async 안에서는 lock()/unlock() 직접 호출 금지 → 스코프 락 사용
        lock.withLock {
            outer: for h in homes.indices {
                for r in homes[h].rooms.indices {
                    if let i = homes[h].rooms[r].devices.firstIndex(where: { $0.id == deviceId }) {
                        homes[h].rooms[r].devices[i].isOn = isOn
                        break outer
                    }
                }
            }
        }
    }

    func refreshAllCharacteristics() async {
        emit()
    }

    private func emit() {
        let snapshot = lock.withLock { homes }
        Task { @MainActor in onHomesUpdated?(snapshot) }
    }
}
#endif
