//
//  StatisticsView.swift
//  LivingStory-iOS
//
//  📱 담당: 이토 (SwiftUI)
//

import SwiftUI

struct StatisticsView: View {

    let coordinator: AppCoordinator

    // TODO: 실제 데이터로 교체
    private let readDates: Set<DateComponents> = [
        DateComponents(year: 2026, month: 2, day: 2),
    ]
    private let monthlyBooks = 24
    private let totalBooks = 95
    private let totalHours = 32

    var body: some View {
            VStack(spacing: 16) {
                ReadingLogCalendar(readDates: readDates)
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
        .navigationTitle("마이")
        .toolbar {
            ToolbarItem {
                Button {
                    // setting시트 열리는 로직
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }

    // MARK: - Subviews

    private var statsSection: some View {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    StatCard(icon: "calendar", title: "이번 달 읽은 책 수", value: "\(monthlyBooks)권")
                    StatCard(icon: "books.vertical.fill", title: "총 읽은 책 수", value: "\(totalBooks)권")
                }
                StatCard(icon: "clock", title: "총 읽은 시간", value: "\(totalHours)시간", isWide: true)
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
        .padding(.vertical, 12)
        .padding(.leading, 10)
        .padding(.trailing, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        StatisticsView(
            coordinator: AppCoordinator(navigationController: UINavigationController())
        )
    }
}
