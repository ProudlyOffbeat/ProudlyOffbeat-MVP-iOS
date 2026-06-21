//
//  NotificationTimeSettingView.swift
//  LivingStory-iOS
//
//  알림 시간 설정 (디자인 897-4898) — 현재 UI만, 값 더미
//

import SwiftUI

struct NotificationTimeSettingView: View {
    let coordinator: AppCoordinator

    // 더미 기본값: 오후 09:30
    @State private var time: Date = {
        var comps = DateComponents()
        comps.hour = 21
        comps.minute = 30
        return Calendar.current.date(from: comps) ?? Date()
    }()
    @State private var isOn = true

    var body: some View {
        ZStack {
            Color.backgroundSecondary.ignoresSafeArea()

            VStack(spacing: 0) {
                SettingIntro(
                    systemImage: "alarm.fill",
                    headline: StringLiterals.Setting.notificationHeadline,
                    subtitle: StringLiterals.Setting.notificationSubtitle
                )

                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .tint(Color(hex: 0xFCDF42))
                    .environment(\.locale, Locale(identifier: "en_US"))
                    .padding(.top, 83)

                HStack {
                    Text(StringLiterals.Setting.notificationToggle)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    Spacer()
                    Toggle("", isOn: $isOn)
                        .labelsHidden()
                        .tint(Color(hex: 0xFFCB24))
                }
                .padding(.leading, 20)
                .padding(.trailing, 12)
                .frame(height: 58)
                .background(Color(hex: 0x2C2C2E), in: RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 20)
                .padding(.top, 77)

                Spacer()
                PrimaryButtonSwiftUI(title: StringLiterals.Setting.done) {
                    coordinator.pop()
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
        NotificationTimeSettingView(coordinator: AppCoordinator(navigationController: UINavigationController()))
    }
}
#endif
