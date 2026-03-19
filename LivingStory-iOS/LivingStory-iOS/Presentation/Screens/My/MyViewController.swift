//
//  MyViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class MyViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    private let repository: ReadingSessionRepositoryProtocol = ReadingSessionRepository()

    // MARK: - UI Components

    private let radialGlowView = RadialGlowView()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button.setImage(UIImage(.settings)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "gray0")
        return button
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private let calendarView = ReadingLogCalendarUIView()

    private let monthlyCard = StatCardView()
    private let totalBookCard = StatCardView()
    private let totalTimeCard = StatCardView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCalendar()
        configureStats()
    }
}

// MARK: - Setup

private extension MyViewController {

    func setupStyle() {
        view.backgroundColor = UIColor(named: "gray100")

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = StringLiterals.My.title
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.title1Emphasized
        ]

        let settingsBarButton = UIBarButtonItem(customView: settingsButton)
        navigationItem.rightBarButtonItem = settingsBarButton
    }

    func setupHierarchy() {
        view.addSubview(radialGlowView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        // 통계 카드 컨테이너
        let cardRow = UIStackView(arrangedSubviews: [monthlyCard, totalBookCard])
        cardRow.axis = .horizontal
        cardRow.spacing = 12
        cardRow.distribution = .fillEqually

        let statsContainer = UIStackView(arrangedSubviews: [cardRow, totalTimeCard])
        statsContainer.axis = .vertical
        statsContainer.spacing = 10  // cardRow ↔ totalTimeCard 간격

        contentStack.addArrangedSubview(calendarView)
        contentStack.addArrangedSubview(statsContainer)

        contentStack.setCustomSpacing(34, after: calendarView)  // 캘린더 ↔ 스탯 컨테이너
    }

    func setupLayout() {
        radialGlowView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radialGlowView.widthAnchor.constraint(equalToConstant: 589),
            radialGlowView.heightAnchor.constraint(equalToConstant: 610),
            radialGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            radialGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    func configureCalendar() {
        calendarView.presenterViewController = self
        let readDates = (try? repository.fetchReadDates()) ?? []
        calendarView.configure(readDates: readDates)
    }

    func configureStats() {
        let monthlyCount = (try? repository.fetchMonthlyBookCount()) ?? 0
        let totalCount = (try? repository.fetchTotalBookCount()) ?? 0

        monthlyCard.configure(
            icon: .calendar,
            title: StringLiterals.My.monthlyBookCount,
            value: "\(monthlyCount)\(StringLiterals.My.readingUnit)"
        )
        totalBookCard.configure(
            icon: .books,
            title: StringLiterals.My.totalBookCount,
            value: "\(totalCount)\(StringLiterals.My.bookUnit)"
        )
        let totalSeconds = (try? repository.fetchTotalSeconds()) ?? 0
        totalTimeCard.configureWide(
            icon: .clock,
            title: StringLiterals.My.totalReadingTime,
            value: ReadingTimeFormatter.format(totalSeconds: totalSeconds)
        )
    }
}
