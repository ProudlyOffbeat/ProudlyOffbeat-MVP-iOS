//
//  SetupCompleteView.swift
//  LivingStory-iOS
//
//  세팅 완료 화면 (#33). 검정 배경 + 120×120 체크(Gradation 100) + 안내.
//

import SwiftUI

struct SetupCompleteView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 230)                  // 체크: 위에서 230

            Image(systemName: "checkmark")
                .font(.system(size: 88, weight: .bold))
                .frame(width: 120, height: 120)          // 120 × 120
                .foregroundStyle(AppGradient.g100.linear) // Gradation 100

            Spacer().frame(height: 20)                   // 체크 ↔ 제목 20

            Text(StringLiterals.OnboardingSetting.completeTitle)
                .font(.headlineMedium)                   // Headline Medium
                .foregroundStyle(.primary)               // Labels Primary

            Spacer().frame(height: 12)                   // 제목 ↔ 부제 12

            Text(StringLiterals.OnboardingSetting.completeSubtitle)
                .font(.calloutParagraph)                 // Callout Paragraph
                .foregroundStyle(.secondary)             // Labels Secondary
                .multilineTextAlignment(.center)

            Spacer()                                     // 나머지 (부제 ≈ 아래에서 340)
        }
        .frame(maxWidth: .infinity)
        .screenBackground(.primary)
    }
}
