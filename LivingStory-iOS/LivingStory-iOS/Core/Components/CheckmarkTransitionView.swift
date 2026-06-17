//
//  CheckmarkTransitionView.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ✅ 체크마크 그리기 전환 인터랙션
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  검은 전체화면에 그라데이션 체크가 펜으로 그려지듯 나타났다가, onFinished 호출.
//  독서 종료 등 "완료" 전환 연출에 재사용 가능.
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct CheckmarkTransitionView: View {

    /// 체크 그리기 + 정지 후 호출 (다음 화면 전환 트리거)
    let onFinished: () -> Void

    /// 그리기 시간
    private let drawDuration: Double = 0.7
    /// 그리기 완료 후 정지(다음 화면 넘어가기 전)
    private let holdDuration: Double = 0.7

    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            CheckShape()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(checkHex: 0xFFCB24), // 노랑 (좌하단)
                            Color(checkHex: 0xBFEE68), // 연두 (중앙)
                            Color(checkHex: 0x4AC3E8)  // 청록 (우상단 끝)
                        ],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 120, height: 120)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: drawDuration)) {
                progress = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + drawDuration + holdDuration) {
                onFinished()
            }
        }
    }
}

// MARK: - Check Shape

/// 체크마크 path (좌측 → 하단 꼭짓점 → 우상단)
private struct CheckShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.20, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.72))
        path.addLine(to: CGPoint(x: w * 0.80, y: h * 0.30))
        return path
    }
}

// MARK: - Color Helper

private extension Color {
    init(checkHex hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    CheckmarkTransitionView(onFinished: {})
}
