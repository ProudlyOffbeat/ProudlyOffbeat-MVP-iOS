//
//  ToastView.swift
//  LivingStory-iOS
//
//  상단에서 내려오는 비차단 토스트. AI 추천 실패 등 가벼운 안내에 사용.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.labelMedium)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.78), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, 20)
    }
}

extension View {
    /// message가 non-nil이면 상단에 토스트를 띄우고 `duration` 뒤 자동 해제.
    func toast(_ message: Binding<String?>, duration: Double = 3.5) -> some View {
        overlay(alignment: .top) {
            if let text = message.wrappedValue {
                ToastView(message: text)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: text) {
                        try? await Task.sleep(for: .seconds(duration))
                        withAnimation(.easeInOut(duration: 0.3)) { message.wrappedValue = nil }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: message.wrappedValue)
    }
}
