//
//  OnboardingPhase.swift
//  LivingStory-iOS
//
//  온보딩 전체 흐름을 지배하는 마스터 상태.
//  View는 이 phase 하나만 보고 무엇을 그릴지 결정한다 (상태가 흩어지지 않음).
//
//  흐름:
//  requestingPermission ──허용──▶ setup(.home) ─ … ─▶ setup(.time) ──▶ completed
//                       └──거부──▶ permissionDenied ──(설정에서 허용/복귀)──▶ setup(...)
//

import Foundation

enum OnboardingPhase: Equatable {
    case requestingPermission     // 권한 다이얼로그 대기 (스플래시 유지)
    case permissionDenied         // 권한 거부 → "홈 앱 권한 허용 필요" 화면
    case setup(SetupStep)         // 세팅 진행 (현재 단계 내장)
    case completed                // 완료 → 메인 진입
}
