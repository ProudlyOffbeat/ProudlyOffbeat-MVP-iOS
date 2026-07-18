//
//  StopReadingView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/8/26.
//
//  책 읽기 완료 화면 (디자인 2757)
//

import SwiftUI

struct StopReadingView: View {
    let coordinator: AppCoordinator
    let book: BookProfileModel
    let conversations: [ConversationProfile]
    /// 이 책을 지금까지 몇 번째 읽었는지 (완료 배지 955-2670)
    var readCount: Int = 1

    var body: some View {
        ZStack {
            Color.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                bookSection

                // 대화주제가 있을 때만 "아이와 대화하기" 노출 (AI 실패로 비었으면 숨김)
                if !conversations.isEmpty {
                    Spacer().frame(height: 48)
                    talkButton
                }

                Spacer()

                bottomButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
        // 네비바 공간은 유지(콘텐츠 위치 고정), 타이틀·뒤로가기·배경만 숨김
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Subviews

    private var bookSection: some View {
        VStack(spacing: 24) {
            BookCoverThumbnail(
                coverURL: book.bookCoverImageURL,
                readCount: readCount   // 실제 읽어준 횟수 (CoreData 세션 카운트)
            )

            VStack(spacing: 12) {
                Text(StringLiterals.Reading.readingDoneTitle)
                    .font(.headlineMedium)
                    .foregroundStyle(.white)
                Text(book.bookTitle)
                    .font(.body2Regular)
                    // Labels/Secondary (iOS 시스템색)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .multilineTextAlignment(.center)
        }
    }

    private var talkButton: some View {
        Button {
            coordinator.showConversation(conversations: conversations)
        } label: {
            HStack(spacing: 6) {
                Image(.conversation)
                    .font(.system(size: 13))
                Text(StringLiterals.Reading.talkWithChild)
                    .font(.buttonSmallMedium)
            }
            .foregroundStyle(Color(hex: 0xF5F5F5))
            .padding(.horizontal, 20)
            .frame(height: 48)
            .glassEffect(.regular, in: Capsule())
        }
    }

    private var bottomButtons: some View {
        VStack(spacing: 14) {
            // 다른 책 읽기 (보조 — 흐린 글래스)
            Button {
                coordinator.restartScanner()
            } label: {
                Capsule()
                    .frame(height: 52)
                    .foregroundStyle(.clear)
                    .glassEffect()
                    .overlay {
                        Text(StringLiterals.Reading.readAnotherBook)
                            .font(.buttonMedium)
                            .foregroundStyle(Color(hex: 0xBFBFBF))
                    }
            }

            // 책 읽기 종료 (주 — 글래스 다크)
            PrimaryButtonSwiftUI(title: StringLiterals.Reading.finishReading) {
                coordinator.showResult()
            }
        }
    }
}

// MARK: - Color Helper

private extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NavigationStack {
        StopReadingView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            book: .mockISBN,
            conversations: []
        )
    }
}
#endif
