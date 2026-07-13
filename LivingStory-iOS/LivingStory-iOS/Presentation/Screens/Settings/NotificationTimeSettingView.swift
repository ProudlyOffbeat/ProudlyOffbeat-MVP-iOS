//
//  NotificationTimeSettingView.swift
//  LivingStory-iOS
//
//  알림 시간 설정 (디자인 897-4898) — 현재 UI만, 값 더미
//

import SwiftUI

struct NotificationTimeSettingView: View {
    @Environment(\.dismiss) private var dismiss

    // 저장값으로 초기화
    @State private var time: Date = UserData.notificationTime
    @State private var isOn: Bool = UserData.notificationEnabled

    var body: some View {
        ZStack {
            Color.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                SettingIntro(
                    symbol: .alarm,
                    headline: StringLiterals.Setting.notificationHeadline,
                    subtitle: StringLiterals.Setting.notificationSubtitle
                )

                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(.yellow60)
                    .environment(\.locale, Locale(identifier: "en_US"))
                    .padding(.top, 83)

                HStack {
                    Text(StringLiterals.Setting.notificationToggle)
                        .font(.calloutRegular)
                        .foregroundStyle(.white)
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(.yellow20)
                }
                .padding(.leading, 20)
                .padding(.trailing, 12)
                .frame(height: 58)
                // Backgrounds/Tertiary (iOS 시스템색)
                .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 20)
                .padding(.top, 77)

                Spacer()
                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    UserData.notificationTime = time
                    UserData.notificationEnabled = isOn
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .preferredColorScheme(.dark)
        .navigationTitle(StringLiterals.Setting.notificationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        NotificationTimeSettingView()
    }
}
#endif
