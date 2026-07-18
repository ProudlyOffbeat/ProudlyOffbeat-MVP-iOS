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
    @State private var permissionDenied = false

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

                // 권한 거부 시 안내 — 앱 내 재요청 불가하므로 iOS 설정으로 유도
                if permissionDenied && isOn {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.yellow60)
                        Text("알림이 꺼져 있어요. 설정 > 나루 > 알림에서 켜주세요")
                            .font(.labelRegular)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                        Button("설정") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .font(.labelMedium)
                        .foregroundStyle(.yellow60)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                Spacer()
                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    UserData.notificationTime = time
                    UserData.notificationEnabled = isOn
                    Task {
                        if isOn {
                            _ = await ReadingNotificationScheduler.shared.requestAuthorization()
                        } else {
                            await ReadingNotificationScheduler.shared.refreshSchedule()
                        }
                    }
                    dismiss()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .task {
            permissionDenied = await ReadingNotificationScheduler.shared.authorizationStatus() == .denied
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
