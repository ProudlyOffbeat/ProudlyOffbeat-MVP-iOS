//
//  ResultView.swift
//  LivingStory-iOS
//
//  Created by 문창재 on 2/12/26.
//

import SwiftUI

struct ResultView: View {

    let coordinator: AppCoordinator
    let repository: ReadingSessionRepositoryProtocol

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(StringLiterals.Reading.todayBookCount((try? repository.fetchTodaySessions().count) ?? 0))
                    .font(.title2Emphasized)
                    .padding(.top, 18)
                    .padding(.horizontal, 20)

                ReadingLogCalendar(readDates: (try? repository.fetchReadDates()) ?? [], showNavigation: false)
                    .border(.red)
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                    

                StatCard(
                    icon: SymbolLiterals.calendar.rawValue,
                    title: StringLiterals.My.monthlyBookCount,
                    value: "\((try? repository.fetchMonthlyBookCount()) ?? 0)\(StringLiterals.My.bookUnit)",
                    isWide: true
                )
                .padding(.horizontal, 20)
            }
            Spacer()

            PrimaryButtonSwiftUI(title: StringLiterals.Reading.homeButton) {
                coordinator.popToHome()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .navigationTitle(StringLiterals.Reading.resultTitle)
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
