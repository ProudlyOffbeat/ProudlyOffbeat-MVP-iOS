//
//  SetupCompleteView.swift
//  LivingStory-iOS
//
//  세팅 완료 화면 (#33). 검정 배경 + 120×120 체크(Gradation 100) + 안내.
//

import SwiftUI

struct SetupCompleteView: View {
    @State private var reveal: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 230)                  // 체크: 위에서 230

            // 새 Check 에셋 — 왼쪽→오른쪽으로 그려지듯 드러남 (책 완료 화면과 동일 연출)
            Image("Check")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .mask(alignment: .leading) {
                    GeometryReader { geo in
                        Rectangle().frame(width: geo.size.width * reveal)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.55)) { reveal = 1 }
                }

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
