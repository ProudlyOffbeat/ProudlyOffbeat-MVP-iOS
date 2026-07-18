//
//  LaunchArguments.swift
//  LivingStory-iOS
//
//  DEBUG 전용 QA 실행 인자. 스킴 ▸ Run ▸ Arguments Passed On Launch 에서 체크로 켜고 끈다.
//  릴리즈 빌드엔 컴파일되지 않아 실서비스엔 영향이 없다.
//

#if DEBUG
import Foundation

enum LaunchArguments {

    private static var args: [String] { ProcessInfo.processInfo.arguments }

    /// 2026-07-03 ~ 오늘까지 "매일 다른 책 1권" 세션을 시드 (스트릭/달력/통계 채우기)
    static var seedStreakData: Bool { args.contains("-SeedStreakData") }

    /// 바코드 조회 실패를 강제 → 스캔 "실패" → 직접 검색 유도
    static var mockBookNotFound: Bool { args.contains("-MockBookNotFound") }

    /// Gemini 429(쿼터 초과) 실패 강제 → 기본 환경으로 진행 + 재추천 알럿
    static var mockGemini429: Bool { args.contains("-MockGemini429") }

    /// Gemini 5xx(서버) 실패 강제 → 기본 환경으로 진행
    static var mockGeminiServerError: Bool { args.contains("-MockGeminiServerError") }
}
#endif
