//
//  StatisticsView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//

import SwiftUI

struct StatisticsView: View {

    let coordinator: AppCoordinator
    let repository: ReadingSessionRepositoryProtocol

    var body: some View {
            VStack(spacing: 16) {
                ReadingLogCalendar(readDates: (try? repository.fetchReadDates()) ?? [])
                    .padding(.top, 25)
                statsSection

                Spacer()
            }
            .padding(.horizontal, 20)
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
        .navigationTitle(StringLiterals.My.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem {
                Button {
                    // setting시트 열리는 로직
                } label: {
                    Image(.settings)
                }
            }
        }
    }

    private var totalTimeString: String {
        let totalSeconds = (try? repository.fetchTotalSeconds()) ?? 0
        return ReadingTimeFormatter.format(totalSeconds: totalSeconds)
    }

    // MARK: - Subviews

    private var statsSection: some View {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    StatCard(icon: SymbolLiterals.calendar.rawValue, title: StringLiterals.My.monthlyBookCount, value: "\((try? repository.fetchMonthlyBookCount()) ?? 0)\(StringLiterals.My.bookUnit)")
                    StatCard(icon: SymbolLiterals.books.rawValue, title: StringLiterals.My.totalBookCount, value: "\((try? repository.fetchTotalBookCount()) ?? 0)\(StringLiterals.My.bookUnit)")
                }
                StatCard(icon: SymbolLiterals.clock.rawValue, title: StringLiterals.My.totalReadingTime, value: totalTimeString, isWide: true)
                Spacer()
            }
    }
}

// MARK: - Subviews

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var isWide: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
            if !isWide {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadlineRegular)
                    Text(value)
                        .font(.subheadlineEmphasized)
                }
            } else {
                HStack {
                    Text(title)
                        .font(.subheadlineRegular)
                    Spacer()
                    Text(value)
                        .font(.subheadlineEmphasized)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
