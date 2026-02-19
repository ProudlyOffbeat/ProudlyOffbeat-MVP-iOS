import SwiftUI

struct ReadingLogCalendar: View {

    let readDates: Set<DateComponents>
    var showNavigation: Bool = true

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private let weekdayColor = Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.3)

    var body: some View {
        VStack(spacing: 20) {
            headerRow
            weekdayRow
            dayGrid
        }
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            HStack(spacing: 4) {
                Text(monthYearString)
                    .font(.title3Emphasized)
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            Spacer()
            if showNavigation {
                HStack(spacing: 28) {
                    Button { changeMonth(by: -1) } label: {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                    Button { changeMonth(by: 1) } label: {
                        Image(systemName: "chevron.right")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.yellow0)
            }
        }
    }

    private var weekdayRow: some View {
        HStack {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(weekdayColor)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        let days = makeDays()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days.indices, id: \.self) { index in
                let day = days[index]
                if day == 0 {
                    Color.clear.frame(height: 44)
                } else {
                    dayCell(day)
                }
            }
        }
        .id(displayedMonth)
        .gesture(showNavigation ?
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 {
                        changeMonth(by: 1)
                    } else if value.translation.width > 50 {
                        changeMonth(by: -1)
                    }
                }
            : nil
        )
    }

    private func dayCell(_ day: Int) -> some View {
        let isToday = isTodayDay(day)
        let isRead = isReadDay(day)

        return Text("\(day)")
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(isToday ? .white : isRead ? .yellow0 : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background {
                Circle()
                    .fill(
                        isToday ? Color.yellow0 :
                        isRead ? Color.yellow0.opacity(0.12) :
                        Color.clear
                    )
                    .frame(width: 44, height: 44)
            }
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: displayedMonth)
    }

    private func makeDays() -> [Int] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let first = calendar.component(.weekday, from: startOfMonth()) - 1
        return Array(repeating: 0, count: first) + Array(1...range.count)
    }

    private func startOfMonth() -> Date {
        guard let date = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else { return displayedMonth }
        return date
    }

    private func isTodayDay(_ day: Int) -> Bool {
        let today = Date()
        return calendar.component(.day, from: today) == day &&
               calendar.isDate(today, equalTo: displayedMonth, toGranularity: .month)
    }

    private func isReadDay(_ day: Int) -> Bool {
        let components = DateComponents(
            year: calendar.component(.year, from: displayedMonth),
            month: calendar.component(.month, from: displayedMonth),
            day: day
        )
        return readDates.contains(components)
    }

    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
                displayedMonth = newMonth
            }
        }
    }
}
