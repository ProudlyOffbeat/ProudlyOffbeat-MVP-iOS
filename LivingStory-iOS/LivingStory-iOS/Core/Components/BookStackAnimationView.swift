//
//  BookStackAnimationView.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 책 3권이 위에서 후두둑 떨어져 쌓이는 애니메이션
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  읽은 권수와 무관하게 항상 3권. 결과창(ResultView) 중앙 그래픽.
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct BookStackAnimationView: View {

    private let count = 3
    private let barWidth: CGFloat = 110
    private let barHeight: CGFloat = 18
    private let verticalGap: CGFloat = 12

    /// 책/스트릭 공용 그라데이션 색 (노랑 → 연두 → 파랑)
    static let gradientColors: [Color] = [
        Color(hex: 0xF2D74E),
        Color(hex: 0x7BDB8A),
        Color(hex: 0x5AC8E8)
    ]

    static var barGradient: LinearGradient {
        LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing)
    }

    @State private var landed = false

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Self.barGradient)
                    .frame(width: barWidth, height: barHeight)
                    .rotationEffect(.degrees(angle(index)))
                    .offset(y: landed ? finalY(index) : finalY(index) - 320)
                    .opacity(landed ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 1)
                        .delay(Double(index) * 0.15),
                        value: landed
                    )
            }
        }
        .frame(height: (barHeight + verticalGap) * CGFloat(count) + 8)
        .onAppear { landed = true }
    }

    // 아래(index 0) → 위(index 2)로 쌓임
    private func finalY(_ index: Int) -> CGFloat {
        let step = barHeight + verticalGap
        return CGFloat(count - 1 - index) * step - CGFloat(count - 1) * step / 2
    }

    // 책처럼 살짝 비스듬히 던져진 각도
    private func angle(_ index: Int) -> Double {
        switch index {
        case 0: return 0   // 아래
        case 1: return -5    // 중간
        default: return 7  // 위
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BookStackAnimationView()
    }
}
