//
//  StopReadingView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/8/26.
//

import SwiftUI

struct StopReadingView: View {
    let coordinator: AppCoordinator
    let bookTitle: String
    let conversations: [ConversationProfile]

    var body: some View {
        VStack {
            conversationSection
            Spacer()
            buttonSection
        }
        .navigationTitle(bookTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var conversationSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("책에 대해 아이와 대화를 나눠보세요.")
                .font(.title2Emphasized)
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(conversations) { item in
                        ConversationCard(
                            question: item.question,
                            effect: item.effect
                        )
                    }
                }
            }
        }
        .padding(.top, 45)
        .padding(.horizontal, 20)
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            PrimaryButtonSwiftUI(title: "다른 책 스캔", action: {})
                .padding(.horizontal, 20)
            WhiteButtonSwiftUI(title: "그만 읽기", action: {
                    coordinator.showResult()
                })
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - Subviews

private struct ConversationCard: View {
    let question: String
    let effect: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CharWrappingText(
                text: question,
                font: .bodyEmphasized
            )
            CharWrappingText(
                text: effect,
                font: .systemFont(ofSize: 15),
                color: .gray40
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.yellow90)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    NavigationView {
        StopReadingView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            bookTitle: "냉장고 먹는 괴물",
            conversations: ConversationProfile.mockList
        )
    }
}
