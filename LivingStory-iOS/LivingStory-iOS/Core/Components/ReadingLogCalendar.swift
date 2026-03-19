import UIKit
import SwiftUI

// MARK: - Shared Format Style

/// Date.FormatStyle: iOS 15+ 권장, value type + Sendable + 내부 캐싱
private let monthYearFormatStyle = Date.FormatStyle()
    .month(.wide)
    .year(.defaultDigits)
    .locale(Locale(identifier: "en_US"))

// MARK: - UIKit Version

final class ReadingLogCalendarUIView: UIView {

    // MARK: - Properties

    private var displayedMonth = Date()
    private var readDates: Set<DateComponents> = []
    var showNavigation: Bool = true

    /// 연도/월 피커를 표시할 VC (sheet present용)
    weak var presenterViewController: UIViewController?

    private lazy var monthYearPicker: MonthYearPickerViewController = {
        let picker = MonthYearPickerViewController(
            selectedDate: displayedMonth
        ) { [weak self] newDate in
            self?.displayedMonth = newDate
            self?.reloadCalendar()
        }
        picker.isModalInPresentation = true
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.custom { _ in 280 }]
            sheet.prefersGrabberVisible = true
        }
        return picker
    }()

    private let cal = Calendar.current
    private let weekdayTitles = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let weekdayColor = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 0.3)

    // MARK: - UI Components

    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()

    private lazy var monthYearButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.image = UIImage(.forward)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .bold))
        config.baseForegroundColor = .label
        config.imageColorTransformer = UIConfigurationColorTransformer { _ in
            UIColor(named: "yellow0") ?? .systemYellow
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(monthYearTapped), for: .touchUpInside)
        return button
    }()

    private lazy var leftButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(.back)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "yellow0")
        button.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        return button
    }()

    private lazy var rightButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(.forward)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "yellow0")
        button.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        return button
    }()

    private let weekdayStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let dayGridStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
        setupWeekdayRow()
        setupSwipeGesture()
        reloadCalendar()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func configure(readDates: Set<DateComponents>) {
        guard self.readDates != readDates else { return }
        self.readDates = readDates
        reloadCalendar()
    }
}

// MARK: - Setup

private extension ReadingLogCalendarUIView {

    func setupHierarchy() {
        addSubview(containerStack)

        // Header
        let navStack = UIStackView(arrangedSubviews: [leftButton, rightButton])
        navStack.axis = .horizontal
        navStack.spacing = 28

        let navContainer = UIView()
        navContainer.addSubview(navStack)
        navStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navStack.topAnchor.constraint(equalTo: navContainer.topAnchor, constant: 7),
            navStack.trailingAnchor.constraint(equalTo: navContainer.trailingAnchor, constant: -16),
            navStack.bottomAnchor.constraint(equalTo: navContainer.bottomAnchor, constant: -9)
        ])

        let spacer = UIView()
        headerStack.addArrangedSubview(monthYearButton)
        headerStack.addArrangedSubview(spacer)
        headerStack.addArrangedSubview(navContainer)

        navContainer.isHidden = !showNavigation

        containerStack.addArrangedSubview(headerStack)
        containerStack.addArrangedSubview(weekdayStack)
        containerStack.addArrangedSubview(dayGridStack)

        containerStack.setCustomSpacing(4, after: headerStack)    // 헤더 ↔ 요일
        containerStack.setCustomSpacing(3, after: weekdayStack)   // 요일 ↔ 첫 날짜행
    }

    func setupLayout() {
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: topAnchor),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func setupWeekdayRow() {
        for title in weekdayTitles {
            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textColor = weekdayColor
            label.textAlignment = .center
            weekdayStack.addArrangedSubview(label)
        }
    }

    func setupSwipeGesture() {
        guard showNavigation else { return }
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        dayGridStack.addGestureRecognizer(swipe)
    }
}

// MARK: - Calendar Logic

private extension ReadingLogCalendarUIView {

    func reloadCalendar() {
        updateHeader()
        reloadDays()
    }

    func updateHeader() {
        var config = monthYearButton.configuration ?? .plain()
        var attr = AttributeContainer()
        attr.font = UIFont.title3Emphasized
        config.attributedTitle = AttributedString(displayedMonth.formatted(monthYearFormatStyle), attributes: attr)
        monthYearButton.configuration = config
    }

    func reloadDays() {
        dayGridStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let days = makeDays()
        var index = 0

        // 최대 6주 (행)
        while index < days.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 0

            for _ in 0..<7 {
                if index < days.count {
                    let day = days[index]
                    let cell = makeDayCell(day)
                    rowStack.addArrangedSubview(cell)
                    index += 1
                } else {
                    rowStack.addArrangedSubview(makeEmptyCell())
                }
            }

            dayGridStack.addArrangedSubview(rowStack)
        }
    }

    func makeDayCell(_ day: Int) -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 44).isActive = true

        guard day > 0 else { return container }

        let isToday = isTodayDay(day)
        let isRead = isReadDay(day)

        // 원형 배경
        let circle = UIView()
        circle.layer.cornerRadius = 22
        circle.clipsToBounds = true
        if isToday {
            circle.backgroundColor = UIColor(named: "yellow0")
        } else if isRead {
            circle.backgroundColor = UIColor(named: "yellow0")?.withAlphaComponent(0.12)
        }

        // 숫자 라벨
        let label = UILabel()
        label.text = "\(day)"
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        if isToday {
            label.textColor = .white
        } else if isRead {
            label.textColor = UIColor(named: "yellow0")
        } else {
            label.textColor = .label
        }

        container.addSubview(circle)
        container.addSubview(label)

        circle.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: 44),
            circle.heightAnchor.constraint(equalToConstant: 44),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        return container
    }

    func makeEmptyCell() -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return view
    }

    // MARK: - Date Helpers

    func makeDays() -> [Int] {
        guard let range = cal.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = cal.component(.weekday, from: startOfMonth()) - 1
        return Array(repeating: 0, count: firstWeekday) + Array(1...range.count)
    }

    func startOfMonth() -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: displayedMonth)) ?? displayedMonth
    }

    func isTodayDay(_ day: Int) -> Bool {
        let today = Date()
        return cal.component(.day, from: today) == day &&
               cal.isDate(today, equalTo: displayedMonth, toGranularity: .month)
    }

    func isReadDay(_ day: Int) -> Bool {
        let components = DateComponents(
            year: cal.component(.year, from: displayedMonth),
            month: cal.component(.month, from: displayedMonth),
            day: day
        )
        return readDates.contains(components)
    }

    func changeMonth(by value: Int) {
        guard let newMonth = cal.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
        UIView.animate(withDuration: 0.2) {
            self.reloadCalendar()
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Actions

private extension ReadingLogCalendarUIView {

    @objc func prevMonth() { changeMonth(by: -1) }
    @objc func nextMonth() { changeMonth(by: 1) }

    @objc func monthYearTapped() {
        monthYearPicker.updateSelectedDate(displayedMonth)
        if let sheet = monthYearPicker.sheetPresentationController {
            sheet.detents = [.custom { _ in 280 }]
            sheet.prefersGrabberVisible = true
        }
        presenterViewController?.present(monthYearPicker, animated: true)
    }

    @objc func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let velocity = gesture.translation(in: dayGridStack).x
        if velocity < -50 { changeMonth(by: 1) }
        else if velocity > 50 { changeMonth(by: -1) }
    }
}

// MARK: - MonthYearPickerViewController

final class MonthYearPickerViewController: UIViewController {

    private var selectedYear: Int
    private var selectedMonth: Int
    private let years: [Int]
    private let yearTitles: [String]
    private let monthTitles: [String]
    private let onDateSelected: (Date) -> Void

    private let pickerView = UIPickerView()

    init(selectedDate: Date, onDateSelected: @escaping (Date) -> Void) {
        let cal = Calendar.current
        self.selectedYear = cal.component(.year, from: selectedDate)
        self.selectedMonth = cal.component(.month, from: selectedDate)
        self.years = Array((selectedYear - 5)...(selectedYear + 5))
        self.yearTitles = years.map { "\($0)년" }
        self.monthTitles = (1...12).map { "\($0)월" }
        self.onDateSelected = onDateSelected
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        selectCurrentDate()
    }

    func updateSelectedDate(_ date: Date) {
        let cal = Calendar.current
        selectedYear = cal.component(.year, from: date)
        selectedMonth = cal.component(.month, from: date)
        if isViewLoaded {
            selectCurrentDate()
        }
    }

    private func setupUI() {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("완료", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.tintColor = UIColor(named: "yellow0")
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

        pickerView.dataSource = self
        pickerView.delegate = self

        view.addSubview(doneButton)
        view.addSubview(pickerView)

        doneButton.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pickerView.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 8),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func selectCurrentDate() {
        if let yearIndex = years.firstIndex(of: selectedYear) {
            pickerView.selectRow(yearIndex, inComponent: 0, animated: false)
        }
        pickerView.selectRow(selectedMonth - 1, inComponent: 1, animated: false)
    }

    @objc private func doneTapped() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            onDateSelected(date)
        }
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate

extension MonthYearPickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        component == 0 ? years.count : 12
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.text = component == 0 ? yearTitles[row] : monthTitles[row]
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 { selectedYear = years[row] }
        else { selectedMonth = row + 1 }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - SwiftUI Version
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ReadingLogCalendar: View {

    let readDates: Set<DateComponents>
    var showNavigation: Bool = true

    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let weekdayColor = Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.3)

    var body: some View {
        VStack(spacing: 3) {
            headerRow
                .padding(.horizontal, 16)
            weekdayRow
            dayGrid
                .padding(.horizontal, 16)
        }
        .padding(.top, 13)
        .padding(.bottom, 17)
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack {
            HStack(spacing: 4) {
                Text(monthYearString)
                    .font(.headline)
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow0)
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
        .padding(.horizontal, 16)
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
        displayedMonth.formatted(monthYearFormatStyle)
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
