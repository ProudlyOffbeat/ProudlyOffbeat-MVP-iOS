//
//  MultiSelectCalendarView.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📅 다중 선택/하이라이트 SwiftUI 캘린더
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  · 읽은 날(선택) = 갈색 채움 + 노란 글자, 탭으로 토글(다중선택)
//  · 오늘 = 초록 채움 + 어두운 글자
//  · MultiDatePicker로는 2톤 커스텀이 불가해 LazyVGrid로 직접 구현.
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI

struct MultiSelectCalendarView: View {

    /// 책 읽은 날짜(표시 전용). 표시 중인 달에 해당하는 날만 하이라이트한다.
    private let readDates: Set<DateComponents>
    /// 오늘 날짜 — 표시 월이 '오늘의 달'일 때만 초록 그라데이션 강조.
    private let today: Date
    /// 과거 슬라이드 하한(최초 독서월의 1일). nil이면 이번 달 이전으로 못 간다.
    private let minMonth: Date?

    /// 표시 중인 달 — 처음엔 이번 달.
    @State private var month: Date
    @State private var showMonthPicker = false

    private var cal: Calendar { Calendar(identifier: .gregorian) }
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8.83), count: 7)

    init(readDates: Set<DateComponents>, today: Date = Date(), minMonth: Date? = nil) {
        self.readDates = readDates
        self.today = today
        self.minMonth = minMonth
        let cal = Calendar(identifier: .gregorian)
        let startOfThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: today)) ?? today
        _month = State(initialValue: startOfThisMonth)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.bottom, 4)
            weekdayRow
            dateGrid
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    // 미래(다음 달)는 이번 달까지, 과거(이전 달)는 최초 독서월까지만 이동 가능.
                    if value.translation.width < -40, canGoNext {
                        withAnimation(.easeInOut(duration: 0.2)) { changeMonth(by: 1) }
                    } else if value.translation.width > 40, canGoPrev {
                        withAnimation(.easeInOut(duration: 0.2)) { changeMonth(by: -1) }
                    }
                }
        )
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPickerSheet(month: $month, minMonth: minMonthEffective, maxMonth: maxMonth)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 4) {
            Text(monthTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Button {
                showMonthPicker = true
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color(hex: 0xFFCB24))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 13)
        .padding(.bottom, 3)
    }

    private var weekdayRow: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(white: 0.92).opacity(0.3))
                    .frame(height: 20)
            }
        }
        .padding(.horizontal, 16)
    }

    private var dateGrid: some View {
        LazyVGrid(columns: columns, spacing: 7) {
            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    private func dayCell(_ day: Int) -> some View {
        let isToday = day == todayDayInMonth
        let isRead = readDaysInMonth.contains(day)

        return Text("\(day)")
            .font(.system(size: 20, weight: isToday ? .semibold : .regular))
            .foregroundStyle(
                isToday ? .white
                : (isRead ? Color(hex: 0xFFCB24) : .white)
            )
            .frame(width: 44, height: 44)
            .background {
                if isToday {
                    Circle().fill(
                        LinearGradient(
                            colors: [Color(hex: 0xBFEE68), Color(hex: 0xFFCB24)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else if isRead {
                    Circle().fill(Color(hex: 0xFFCB24).opacity(0.16))
                }
            }
    }

    // MARK: - Logic

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }

    /// 앞 빈칸(nil) + 1...말일
    private var monthDays: [Int?] {
        let comps = cal.dateComponents([.year, .month], from: month)
        guard let first = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: first) else { return [] }
        let leading = cal.component(.weekday, from: first) - 1 // 1=Sun
        return Array(repeating: nil, count: leading) + range.map { Optional($0) }
    }

    private func changeMonth(by value: Int) {
        guard let next = cal.date(byAdding: .month, value: value, to: month) else { return }
        // 범위 밖이면 무시 (스와이프 가드와 이중 안전장치)
        guard next >= minMonthEffective, next <= maxMonth else { return }
        month = next
    }

    // MARK: - 표시/경계 계산

    private func startOfMonth(_ date: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: date)) ?? date
    }

    /// 미래 상한 = 이번 달 (독서 기록앱이라 빈 미래월로는 못 넘어간다)
    private var maxMonth: Date { startOfMonth(today) }
    /// 과거 하한 = 최초 독서월. 기록 없으면 이번 달.
    private var minMonthEffective: Date { minMonth ?? maxMonth }
    private var canGoPrev: Bool { startOfMonth(month) > minMonthEffective }
    private var canGoNext: Bool { startOfMonth(month) < maxMonth }

    /// 표시 중인 달에 속한 '읽은 날'들의 일(day) 집합
    private var readDaysInMonth: Set<Int> {
        let comps = cal.dateComponents([.year, .month], from: month)
        return Set(readDates.compactMap { d -> Int? in
            guard d.year == comps.year, d.month == comps.month, let day = d.day else { return nil }
            return day
        })
    }

    /// 표시 중인 달이 '오늘의 달'이면 오늘 일(day), 아니면 nil
    private var todayDayInMonth: Int? {
        let m = cal.dateComponents([.year, .month], from: month)
        let t = cal.dateComponents([.year, .month, .day], from: today)
        return (m.year == t.year && m.month == t.month) ? t.day : nil
    }
}

// MARK: - 연/월 선택 시트

private struct MonthYearPickerSheet: View {
    @Binding var month: Date
    let minMonth: Date
    let maxMonth: Date
    @Environment(\.dismiss) private var dismiss

    @State private var year: Int
    @State private var monthNum: Int

    private let cal = Calendar(identifier: .gregorian)

    init(month: Binding<Date>, minMonth: Date, maxMonth: Date) {
        _month = month
        self.minMonth = minMonth
        self.maxMonth = maxMonth
        let cal = Calendar(identifier: .gregorian)
        _year = State(initialValue: cal.component(.year, from: month.wrappedValue))
        _monthNum = State(initialValue: cal.component(.month, from: month.wrappedValue))
    }

    /// 선택 가능한 연도 범위 = [최초 독서년 … 올해]
    private var yearRange: ClosedRange<Int> {
        let lower = cal.component(.year, from: minMonth)
        let upper = cal.component(.year, from: maxMonth)
        return lower...max(lower, upper)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("완료") {
                    apply()
                    dismiss()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color(hex: 0xFFCB24))
            }
            .padding(16)

            HStack(spacing: 0) {
                Picker("연도", selection: $year) {
                    ForEach(yearRange, id: \.self) { Text("\($0)년").tag($0) }
                }
                .pickerStyle(.wheel)

                Picker("월", selection: $monthNum) {
                    ForEach(1...12, id: \.self) { Text("\($0)월").tag($0) }
                }
                .pickerStyle(.wheel)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func apply() {
        var comps = DateComponents()
        comps.year = year
        comps.month = monthNum
        comps.day = 1
        guard let date = cal.date(from: comps) else { return }
        // 범위 밖 선택은 경계로 클램프 (예: 최초 독서월 이전 → 최초 독서월)
        month = min(max(date, minMonth), maxMonth)
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

#Preview {
    let cal = Calendar(identifier: .gregorian)
    let today = cal.startOfDay(for: Date())
    // 더미: 이번 달 최근 연속 3일 + 2개월 전 1건(과거 슬라이드 하한 확인)
    var dates = Set<DateComponents>()
    for offset in 0...2 {
        if let d = cal.date(byAdding: .day, value: -offset, to: today) {
            dates.insert(cal.dateComponents([.year, .month, .day], from: d))
        }
    }
    let past = cal.date(byAdding: .month, value: -2, to: today)!
    dates.insert(cal.dateComponents([.year, .month, .day], from: past))
    let minMonth = cal.date(from: cal.dateComponents([.year, .month], from: past))

    return ZStack {
        Color(red: 0.11, green: 0.11, blue: 0.12).ignoresSafeArea()
        MultiSelectCalendarView(readDates: dates, today: today, minMonth: minMonth)
    }
    .preferredColorScheme(.dark)
}
