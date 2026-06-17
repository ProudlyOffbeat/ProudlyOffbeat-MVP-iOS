//
//  BookCoverThumbnail.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📕 책 표지 썸네일 (150×200) + 읽은 횟수 배지
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  BookProfileView(환경 미리보기) · StopReadingView(책 읽기 완료) 공용.
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct BookCoverThumbnail: View {
    let coverURL: URL?
    /// 해당 책을 몇 번째 읽었는지 (현재 더미)
    let readCount: Int

    var body: some View {
        cover
            .frame(width: 150, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(white: 0.92).opacity(0.16), lineWidth: 1)
            }
            // 배지를 클립된 표지 바운즈(150×200) 기준으로 고정 — 이미지 유무와 무관하게 동일 위치
            .overlay(alignment: .bottomTrailing) {
                ReadCountBadge(count: readCount)
                    .offset(x: 28, y: -8)
            }
    }

    @ViewBuilder
    private var cover: some View {
        if let coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Color(thumbHex: 0x2C2C2E)
                }
            }
        } else {
            Color(thumbHex: 0x2C2C2E)
        }
    }
}

private struct ReadCountBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "book.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color(thumbHex: 0xFFCB24))
            Text("\(count)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(thumbHex: 0xFFCB24), Color(thumbHex: 0xBFEE68)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.black, in: Capsule())
    }
}

private extension Color {
    init(thumbHex hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

#Preview {
    ZStack {
        Color(red: 0.11, green: 0.11, blue: 0.12).ignoresSafeArea()
        BookCoverThumbnail(coverURL: nil, readCount: 4)
    }
    .preferredColorScheme(.dark)
}
