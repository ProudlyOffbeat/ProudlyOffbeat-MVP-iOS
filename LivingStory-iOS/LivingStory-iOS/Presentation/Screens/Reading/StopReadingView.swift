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
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Subviews

    private var conversationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Image(.conversation)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26)
                Text(StringLiterals.Reading.conversationPrompt)
                    .font(.title2Medium)
            }
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(conversations) { item in
                        ConversationCard(
                            question: item.question,
                            effect: item.effect
                        )
                    }
                }
            }
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            PrimaryButtonSwiftUI(title: StringLiterals.Reading.restartScan, action: {
                    coordinator.restartScanner()
                })
            WhiteButtonSwiftUI(title: StringLiterals.Reading.stopReadingButton, action: {
                    coordinator.showResult()
                })
        }
    }
}

// MARK: - Subviews

private struct ConversationCard: View {
    let question: String
    let effect: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CharWrappingText(text: question, font: .body2Medium, color: .gray10)
            CharWrappingText(
                text: effect,
                font: .calloutRegular,
                color: .gray40
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.yellow0)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
