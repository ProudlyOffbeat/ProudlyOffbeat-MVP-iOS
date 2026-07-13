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

    // 저장값(UserData) 반영 — 루트로 복귀 시 .onAppear가 다시 불려 재로드되므로 즉시 갱신됨
    @State private var childAge: String = ""
    @State private var notificationTime: String = ""

    private let homeName = "서울 집"
    private let appVersion = "1.0.0"

    /// 오후 09:30 형식
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh:mm"
        return formatter
    }()

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
        .onAppear { reload() }
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
                    Image(.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Data

    /// 진입/복귀 시 저장값을 화면 상태로 재로드
    private func reload() {
        childAge = "\(UserData.childAge)살"
        notificationTime = Self.timeFormatter.string(from: UserData.notificationTime)
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
                    Image(.forward)
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
