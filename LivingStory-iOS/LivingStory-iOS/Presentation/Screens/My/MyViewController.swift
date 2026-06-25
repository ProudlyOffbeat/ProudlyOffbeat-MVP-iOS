//
//  MyViewController.swift
//  LivingStory-iOS
//
//  내 독서 요약 — 헤더 + 히어로(이번 달 횟수) + 웨이브 + 캘린더 + 총 읽어준 책.
//

import UIKit

final class MyViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    private let repository: ReadingSessionRepositoryProtocol = ReadingSessionRepository()
    private let bookRepository: BookRepositoryProtocol = BookRepository()

    // MARK: - Nav

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button.setImage(UIImage(.settings)?.withConfiguration(config), for: .normal)
        button.tintColor = .white
        return button
    }()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView = UIView()

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "독서 요약"
        label.font = .title1SemiBold
        label.textColor = .white
        return label
    }()

    private let streakBadge = StreakBadgeView()

    // MARK: - Hero

    private let yearMonthLabel: UILabel = {
        let label = UILabel()
        label.font = .calloutRegular
        label.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.3)   // Labels Tertiary
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 달에 책을 이만큼 읽어줬어요!"
        label.font = .body1Regular
        label.textColor = .label
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.text = "번"
        label.font = .title2Medium
        label.textColor = .label
        return label
    }()

    private let waveImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Intro"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Calendar / Books

    private let calendarView = ReadingLogCalendarUIView()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.1)
        return view
    }()

    private let booksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 읽어준 책"
        label.font = .body2Medium
        label.textColor = .white
        return label
    }()

    private let booksCountLabel: UILabel = {
        let label = UILabel()
        label.font = .body1Regular
        label.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)   // Secondary
        return label
    }()

    private let booksChevron: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let booksScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let booksStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupHierarchy()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCalendar()
        configureStats()
        configureBooks()
    }
}

// MARK: - Setup

private extension MyViewController {

    func setupNavigation() {
        // 큰 타이틀은 콘텐츠에서 직접 그림 → nav 바엔 톱니만
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }

    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 웨이브가 맨 뒤(히어로 텍스트 뒤)
        [waveImageView,
         titleLabel, streakBadge,
         yearMonthLabel, descriptionLabel, countLabel, unitLabel,
         calendarView, separatorView,
         booksTitleLabel, booksCountLabel, booksChevron,
         booksScrollView].forEach { contentView.addSubview($0) }

        booksScrollView.addSubview(booksStack)
    }

    func setupLayout() {
        [scrollView, contentView, waveImageView,
         titleLabel, streakBadge,
         yearMonthLabel, descriptionLabel, countLabel, unitLabel,
         calendarView, separatorView,
         booksTitleLabel, booksCountLabel, booksChevron,
         booksScrollView, booksStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // 헤더
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            streakBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            streakBadge.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            // 히어로
            yearMonthLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 50),
            yearMonthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            descriptionLabel.topAnchor.constraint(equalTo: yearMonthLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            countLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            unitLabel.leadingAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 2),
            unitLabel.lastBaselineAnchor.constraint(equalTo: countLabel.lastBaselineAnchor),

            // 웨이브 (타이틀서 78, 풀블리드, 비율 유지)
            waveImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            waveImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            waveImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            waveImageView.heightAnchor.constraint(equalTo: waveImageView.widthAnchor, multiplier: 205.0 / 320.0),

            // 캘린더 (웨이브서 15)
            calendarView.topAnchor.constraint(equalTo: waveImageView.bottomAnchor, constant: 15),
            calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // 구분선 (1px, 좌우 8, 위 8)
            separatorView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            // 총 읽어준 책 헤더 (구분선서 24)
            booksTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 24),
            booksTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            booksCountLabel.leadingAnchor.constraint(equalTo: booksTitleLabel.trailingAnchor, constant: 8),
            booksCountLabel.firstBaselineAnchor.constraint(equalTo: booksTitleLabel.firstBaselineAnchor),

            booksChevron.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            booksChevron.centerYAnchor.constraint(equalTo: booksTitleLabel.centerYAnchor),
            booksChevron.widthAnchor.constraint(equalToConstant: 14),

            // 책 커버 (헤더서 24)
            booksScrollView.topAnchor.constraint(equalTo: booksTitleLabel.bottomAnchor, constant: 24),
            booksScrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            booksScrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            booksScrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            booksStack.topAnchor.constraint(equalTo: booksScrollView.topAnchor),
            booksStack.leadingAnchor.constraint(equalTo: booksScrollView.leadingAnchor, constant: 20),
            booksStack.trailingAnchor.constraint(equalTo: booksScrollView.trailingAnchor, constant: -20),
            booksStack.bottomAnchor.constraint(equalTo: booksScrollView.bottomAnchor),
            booksStack.heightAnchor.constraint(equalTo: booksScrollView.heightAnchor)
        ])
    }

    // MARK: - Data

    func configureCalendar() {
        calendarView.presenterViewController = self
        let readDates = (try? repository.fetchReadDates()) ?? []
        calendarView.configure(readDates: readDates)
    }

    func configureStats() {
        let monthlyCount = (try? repository.fetchMonthlyBookCount()) ?? 0   // 이번 달 읽어준 횟수(세션 수)
        countLabel.attributedText = NSAttributedString(
            string: "\(monthlyCount)",
            attributes: [
                .font: UIFont.largeTitleMedium,
                .foregroundColor: UIColor.label,
                .kern: -2.24    // 56 × -4%
            ]
        )

        yearMonthLabel.text = currentYearMonthText()
        streakBadge.configure(count: computeStreak())

        let totalCount = (try? repository.fetchTotalBookCount()) ?? 0
        booksCountLabel.text = "\(totalCount)"
    }

    func configureBooks() {
        booksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let books = (try? bookRepository.fetchAllBooks()) ?? []
        for book in books {
            booksStack.addArrangedSubview(makeBookCoverView(book))
        }
    }

    // MARK: - Helpers

    func currentYearMonthText() -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return "\(comps.year ?? 2026)년 \(comps.month ?? 1)월"
    }

    /// 오늘부터 거슬러 연속으로 읽은 날 수
    func computeStreak() -> Int {
        let readDates = (try? repository.fetchReadDates()) ?? []
        let cal = Calendar.current
        let readDays = Set(readDates.compactMap { cal.date(from: $0).map { cal.startOfDay(for: $0) } })
        var streak = 0
        var day = cal.startOfDay(for: Date())
        while readDays.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func makeBookCoverView(_ book: BookProfileModel) -> UIView {
        let container = UIView()

        let cover = UIImageView()
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 8
        cover.backgroundColor = UIColor(hex: 0x3A3A3C)
        loadCover(book.bookCoverImageURL, into: cover)

        let title = UILabel()
        title.text = book.bookTitle
        title.font = .footnoteRegular
        title.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)
        title.lineBreakMode = .byTruncatingTail

        [container, cover, title].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        container.addSubview(cover)
        container.addSubview(title)

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: 110),
            cover.topAnchor.constraint(equalTo: container.topAnchor),
            cover.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cover.heightAnchor.constraint(equalToConstant: 150),
            title.topAnchor.constraint(equalTo: cover.bottomAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    func loadCover(_ url: URL?, into imageView: UIImageView) {
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { imageView.image = image }
        }.resume()
    }
}
