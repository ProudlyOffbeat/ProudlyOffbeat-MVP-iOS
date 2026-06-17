//
//  ConversationView.swift
//  LivingStory-iOS
//
//  아이와 대화 나누기 — 책에 대한 대화 주제 리스트
//  (책 읽기 완료 화면의 '아이와 대화 나누기'에서 진입)
//

import SwiftUI

struct ConversationView: View {
    let coordinator: AppCoordinator
    let bookTitle: String
    let conversations: [ConversationProfile]

    var body: some View {
        ZStack {
            Color(hex: 0x1C1C1E)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(.conversation)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26)
                            Text(StringLiterals.Reading.conversationPrompt)
                                .font(.title2Emphasized)
                                .foregroundStyle(.white)
                        }

                        VStack(spacing: 16) {
                            ForEach(conversations) { item in
                                ConversationCard(
                                    question: item.question,
                                    effect: item.effect
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(bookTitle)
                .font(.headlineRegular)
                .foregroundStyle(.white)
                .lineLimit(1)

            HStack {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }
}

// MARK: - Conversation Card

private struct ConversationCard: View {
    let question: String
    let effect: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CharWrappingText(text: question, font: .bodyLargeMedium, color: .gray10)
            CharWrappingText(
                text: effect,
                font: .calloutRegular,
                color: .gray40
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.yellow90)
        .clipShape(RoundedRectangle(cornerRadius: 18))
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
