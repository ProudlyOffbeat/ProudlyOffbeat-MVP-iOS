//
//  ResultView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/12/26.
//

import SwiftUI

struct ResultView: View {

    let coordinator: AppCoordinator

    // TODO: 실제 데이터로 교체
    private let todayBooks = 3
    private let monthlyBooks = 24
    private let readDates: Set<DateComponents> = [
        DateComponents(year: 2026, month: 2, day: 2),
        DateComponents(year: 2026, month: 2, day: 3),
        DateComponents(year: 2026, month: 2, day: 5),
        DateComponents(year: 2026, month: 2, day: 8),
        DateComponents(year: 2026, month: 2, day: 9),
        DateComponents(year: 2026, month: 2, day: 10),
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("오늘 \(todayBooks)권의 책을 읽었어요!")
                    .font(.title2Emphasized)
                    .padding(.top, 33)

                ReadingLogCalendar(readDates: readDates, showNavigation: false)
                    .padding(.top, 33)

                StatCard(
                    icon: "calendar",
                    title: "이번 달 읽은 책 수",
                    value: "\(monthlyBooks)권",
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
