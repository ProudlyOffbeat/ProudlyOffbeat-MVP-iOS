//
//  SetupScaffold.swift
//  LivingStory-iOS
//
//  세팅 플로우 모든 단계의 공통 뼈대.
//  상단(뒤로 + 진행도) / 헤더(아이콘·타이틀·서브타이틀) / 콘텐츠 / 하단(건너뛰기 + CTA).
//

import SwiftUI

struct SetupScaffold<Content: View>: View {

    let step: SetupStep
    let progress: (current: Int, total: Int)
    var showsBack: Bool = true
    var isCTAEnabled: Bool = true
    let onBack: () -> Void
    let onCTA: () -> Void
    var onSkip: (() -> Void)?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 상단: 뒤로 + 진행도
            ZStack {
                ProgressDots(current: progress.current, total: progress.total)
                    .frame(maxWidth: .infinity)
                HStack {
                    if showsBack {
                        Button(action: onBack) {
                            Image(.back)
                                .font(.body1SemiBold)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .glassEffect(.clear, in: .circle)   // 클리어 리퀴드 글래스
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 44)        // 뒤로 버튼 유무와 무관하게 고정 → 아래 요소가 안 밀림
            .padding(.top, 10)        // 상태바 ↔ 상단바 10

            // 헤더
            Image(step.icon)
                .font(.system(size: 26))
                .foregroundStyle(.secondary)
                .padding(.top, 32)

            Text(step.title)
                .font(.title3SemiBold)
                .tracking(0.26)                  // Title3 SemiBold letter spacing +1% (26 × 0.01)
                .foregroundStyle(.primary)       // Label Primary
                .padding(.top, 36)               // 심볼 ↔ 타이틀 36

            Text(step.subtitle)
                .font(.body2Light)
                .tracking(0.18)                  // Body2 Light letter spacing +1% (18 × 0.01)
                .foregroundStyle(.secondary)     // Label Secondary
                .padding(.top, 4)

            // 콘텐츠
            content()
                .padding(.top, 40)

            Spacer(minLength: 24)

            // 하단 — 건너뛰기 ↔ 버튼 32
            VStack(spacing: 32) {
                if let onSkip {
                    Button(action: onSkip) {
                        Text(StringLiterals.OnboardingSetting.skip)
                            .font(.calloutRegular)        // Callout Regular
                            .foregroundStyle(.secondary)  // Labels Secondary
                    }
                    .buttonStyle(.plain)                  // 파랑 틴트 제거
                }
                PrimaryButtonSwiftUI(title: step.ctaTitle, height: 56, action: onCTA)
                    .disabled(!isCTAEnabled)
                    .opacity(isCTAEnabled ? 1 : 0.4)
            }
        }
        .padding(.horizontal, 20)        // 모든 요소 양측 20
        .padding(.bottom, 30)            // 버튼 하단 30
        .screenBackground(.secondary)
    }
}

// MARK: - Progress Dots

struct ProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < current ? Color.white : Color.white.opacity(0.25))
                    .frame(width: 7, height: 7)
            }
        }
    }
}
