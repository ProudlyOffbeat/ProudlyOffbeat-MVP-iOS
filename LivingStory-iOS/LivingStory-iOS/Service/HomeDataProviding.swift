//
//  HomeDataProviding.swift
//  LivingStory-iOS
//
//  HomeViewController가 의존하는 "집/기기 데이터 소스" 추상화.
//  실제(HomeKitManager)와 목업(MockHomeProvider)을 갈아끼워 UI를 테스트한다.
//

import Foundation

protocol HomeDataProviding: AnyObject {
    /// 집 목록 갱신 콜백 (항상 메인에서 호출)
    var onHomesUpdated: (@MainActor ([HomeModel]) -> Void)? { get set }
    /// 권한 거부 콜백 (항상 메인에서 호출)
    var onPermissionDenied: (@MainActor () -> Void)? { get set }

    /// 초기 상태 확인 → 준비되면 onHomesUpdated/onPermissionDenied 호출
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
    /// 실행 인자/환경변수로 목업 데이터 주입 (DEBUG 빌드에서만).
    ///   • Xcode Scheme ▸ Run ▸ Arguments 에 `-UITestMockHome` 추가, 또는
    ///   • 환경변수 `MOCK_HOME=1`, 또는 XCUITest `app.launchArguments = ["-UITestMockHome"]`
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
