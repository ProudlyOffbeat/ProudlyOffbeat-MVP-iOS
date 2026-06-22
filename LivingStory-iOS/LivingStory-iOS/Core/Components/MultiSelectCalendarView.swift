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

    /// 표시 중인 달 (더미: 2025년 4월)
    @State private var month: Date = {
        var c = DateComponents()
        c.year = 2025; c.month = 4; c.day = 1
        return Calendar(identifier: .gregorian).date(from: c) ?? Date()
    }()

    /// 책 읽은 날 — 더미 (데이터 표시 전용, 탭으로 바뀌지 않음)
    private let readDays: Set<Int> = [8, 9, 10, 12, 14, 15]

    /// 오늘(초록 강조) — 더미
    private let todayDay = 20

    @State private var showMonthPicker = false

    private var cal: Calendar { Calendar(identifier: .gregorian) }
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8.83), count: 7)

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
                    if value.translation.width < -40 {
                        withAnimation(.easeInOut(duration: 0.2)) { changeMonth(by: 1) }
                    } else if value.translation.width > 40 {
                        withAnimation(.easeInOut(duration: 0.2)) { changeMonth(by: -1) }
                    }
                }
        )
        .sheet(isPresented: $showMonthPicker) {
            MonthYearPickerSheet(month: $month)
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
        let isToday = day == todayDay
        let isRead = readDays.contains(day)

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
        if let next = cal.date(byAdding: .month, value: value, to: month) {
            month = next
        }
    }
}

// MARK: - 연/월 선택 시트

private struct MonthYearPickerSheet: View {
    @Binding var month: Date
    @Environment(\.dismiss) private var dismiss

    @State private var year: Int
    @State private var monthNum: Int

    private let cal = Calendar(identifier: .gregorian)

    init(month: Binding<Date>) {
        _month = month
        let cal = Calendar(identifier: .gregorian)
        _year = State(initialValue: cal.component(.year, from: month.wrappedValue))
        _monthNum = State(initialValue: cal.component(.month, from: month.wrappedValue))
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
                    ForEach(2020...2030, id: \.self) { Text("\($0)년").tag($0) }
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
        if let date = cal.date(from: comps) { month = date }
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
    ZStack {
        Color(red: 0.11, green: 0.11, blue: 0.12).ignoresSafeArea()
        MultiSelectCalendarView()
    }
    .preferredColorScheme(.dark)
}
