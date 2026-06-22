//
//  HomeSelectionView.swift
//  LivingStory-iOS
//
//  집 선택 (디자인 897-4933) — 현재 UI만, 값 더미
//

import SwiftUI

struct HomeSelectionView: View {
    @Environment(\.dismiss) private var dismiss

    // 더미 목록 / 선택
    private let homes = ["서울 집", "남양주 집"]
    @State private var selectedIndex = 0

    var body: some View {
        ZStack {
            Color.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                SettingIntro(
                    systemImage: "house.fill",
                    headline: StringLiterals.Setting.homeHeadline,
                    subtitle: StringLiterals.Setting.homeSubtitle
                )

                homeList
                    .padding(.horizontal, 20)
                    .padding(.top, 53)

                Spacer()

                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .navigationTitle(StringLiterals.Setting.homeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var homeList: some View {
        VStack(spacing: 0) {
            ForEach(Array(homes.enumerated()), id: \.offset) { index, name in
                Button {
                    selectedIndex = index
                } label: {
                    HStack {
                        Text(name)
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                        Spacer()
                        if selectedIndex == index {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.yellow60)
                        }
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 12)
                    .frame(height: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < homes.count - 1 {
                    Divider()
                        .overlay(Color(hex: 0x48484A))
                        .padding(.horizontal, 20)
                }
            }
        }
        // Backgrounds/Tertiary (iOS 시스템색)
        .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 26))
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

#if DEBUG
#Preview {
    NavigationStack {
        HomeSelectionView()
    }
}
#endif
