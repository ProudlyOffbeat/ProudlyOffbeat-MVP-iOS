//
//  SettingsView.swift
//  LivingStory-iOS
//
//  설정 메인 (디자인 897-4792) — 현재 UI만, 값 더미
//

import SwiftUI

struct SettingsView: View {
    let coordinator: AppCoordinator
    @Binding var path: [SettingsRoute]

    // TODO: 실제 설정값 연동 (현재 더미)
    private let childAge = "7살"
    private let notificationTime = "오후 09:30"
    private let homeName = "서울 집"
    private let appVersion = "1.0.0"

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                section(StringLiterals.Setting.childInfoSection) {
                    SettingsRow(title: StringLiterals.Setting.childAge, value: childAge) {
                        path.append(.childAge)
                    }
                }

                section(StringLiterals.Setting.notificationSection) {
                    SettingsRow(title: StringLiterals.Setting.notificationTime, value: notificationTime) {
                        path.append(.notification)
                    }
                }

                section(StringLiterals.Setting.environmentSection) {
                    SettingsRow(title: StringLiterals.Setting.home, value: homeName) {
                        path.append(.home)
                    }
                }

                section(StringLiterals.Setting.appInfoSection) {
                    VStack(spacing: 0) {
                        SettingsRow(title: StringLiterals.Setting.version, value: appVersion, showChevron: false)
                        Divider().overlay(Color.white.opacity(0.08)).padding(.horizontal, 18)
                        SettingsRow(title: StringLiterals.Setting.privacy) {
                            // TODO: 개인정보처리방침 연결
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
        // 배경은 .background로 풀블리드, ScrollView는 세이프에어리어 준수 → Large 타이틀 정상 동작
        .background(Color.backgroundSecondary.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .navigationTitle(StringLiterals.Setting.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            // 설정 루트 → 설정 빠져나가기(UIKit pop으로 Statistics 복귀)
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    coordinator.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Section

    private func section<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.labelRegular)
                .foregroundStyle(Color(white: 0.92).opacity(0.4))
                .padding(.leading, 4)

            content()
                // Backgrounds/Tertiary (iOS 시스템색)
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 26))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    let title: String
    var value: String? = nil
    var showChevron: Bool = true
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 8) {
                Text(title)
                    .font(.calloutRegular)
                    .foregroundStyle(.white)
                Spacer()
                if let value {
                    Text(value)
                        .font(.calloutRegular)
                        .foregroundStyle(Color(white: 0.92).opacity(0.5))
                }
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.yellow20)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView(
            coordinator: AppCoordinator(navigationController: UINavigationController()),
            path: .constant([])
        )
    }
}
#endif
