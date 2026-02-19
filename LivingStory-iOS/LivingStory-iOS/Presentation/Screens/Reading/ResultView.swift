//
//  ResultView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/12/26.
//

import SwiftUI

struct ResultView: View {

    let coordinator: AppCoordinator
    private let store = ReadingSessionStore.shared

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("오늘 \(store.todayBookCount)권의 책을 읽었어요!")
                    .font(.title2Emphasized)
                    .padding(.top, 33)

                ReadingLogCalendar(readDates: store.readDateComponents, showNavigation: false)
                    .padding(.top, 33)

                StatCard(
                    icon: "calendar",
                    title: "이번 달 읽은 책 수",
                    value: "\(store.monthlyBookCount)권",
                    isWide: true
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            PrimaryButtonSwiftUI(title: "홈으로") {
                coordinator.popToHome()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle("읽은 책")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(
            RadialGradient(
                colors: [
                    Color(red: 1, green: 0.77, blue: 0.016).opacity(0.2),
                    Color(red: 1, green: 0.77, blue: 0.016).opacity(0)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 305
            )
            .frame(width: 589, height: 610)
            .offset(y: 150)
        )
    }
}

#Preview {
    NavigationView {
        ResultView(
            coordinator: AppCoordinator(navigationController: UINavigationController())
        )
    }
}
