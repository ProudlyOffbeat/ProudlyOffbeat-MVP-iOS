//
//  ConversationView.swift
//  LivingStory-iOS
//
//  아이와 대화 나누기 — 책에 대한 대화 주제 아코디언 리스트
//  (책 읽기 완료 화면의 '아이와 대화 나누기'에서 진입)
//

import SwiftUI

struct ConversationView: View {
    let coordinator: AppCoordinator
    let conversations: [ConversationProfile]

    /// 펼쳐진 카드 인덱스 (한 번에 하나만, 첫 카드 기본 펼침)
    @State private var expandedIndex: Int? = 0

    var body: some View {
        ZStack {
            Color.backgroundSecondary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(conversations.enumerated()), id: \.element.id) { index, item in
                            ConversationAccordionCard(
                                index: index,
                                effect: item.effect,
                                question: item.question,
                                isExpanded: expandedIndex == index
                            ) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    expandedIndex = (expandedIndex == index) ? nil : index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            // 제목 색을 시스템 네비바(앱 라이트 고정→검정)에 맡기지 않고 흰색 콘텐츠로 직접 렌더
            ToolbarItem(placement: .principal) {
                Text(StringLiterals.Reading.conversationTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Accordion Card

private struct ConversationAccordionCard: View {
    let index: Int
    let effect: String
    let question: String
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                numberBadge
                Text(effect)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: 0xBFEE68))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if isExpanded {
                Text(question)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 6)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 30))
        .contentShape(RoundedRectangle(cornerRadius: 30))
        .onTapGesture(perform: onTap)
    }

    private var numberBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "ellipsis.message.fill")
                .font(.system(size: 11))
            Text(String(format: "%02d", index + 1))
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(Color(hex: 0x121212))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xFFCB24), Color(hex: 0xBFEE68)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: Capsule()
        )
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
        ConversationView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            conversations: ReadingEnvironment.mock.toConversationProfiles()
        )
    }
}
#endif
