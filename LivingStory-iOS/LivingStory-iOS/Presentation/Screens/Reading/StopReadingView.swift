//
//  StopReadingView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/8/26.
//

import SwiftUI

struct Conversation: Identifiable {
    let id = UUID()
    let question: String
    let effect: String

    static let mock: [Conversation] = [
        Conversation(question: "어린왕자가 장미를 그리워할 때 어떤 마음이었을까?", effect: "공감 능력과 표현력을 길러줘요"),
        Conversation(question: "상자 속에 어떤 양이 살고 있을까? OO이가 상상하는 양을 말해줘!", effect: "고정관념을 깨고 본질을 생각하게 해요"),
        Conversation(question: "OO이만의 별이 있다면 무엇을 가져가고 싶어?", effect: "창의력과 자기표현을 도와줘요"),
    ]
}

struct StopReadingView: View {
    let coordinator: AppCoordinator
    let conversations: [Conversation]

    var body: some View {
        VStack {
            conversationSection
            Spacer()
            buttonSection
        }
        .navigationTitle("완다는 별의 소리를 들어요")
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
            WhiteButtonSwiftUI(title: "그만 읽기", action: {})
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
            conversations: Conversation.mock
        )
    }
}
