//
//  BookViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit
import SwiftUI

final class BookViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    private let bookDataSource = BookDataSource()
    private let readingRepository: ReadingSessionRepositoryProtocol = ReadingSessionRepository()

    // MARK: - UI Components

    private let bookTitleLabel: UILabel = {
        let label = UILabel()
        label.text = StringLiterals.Book.title
        label.font = .title1SemiBold
        label.textColor = .white
        return label
    }()

    private let streakBadge = StreakBadgeView()


    private lazy var collectionView: UICollectionView = {
        let layout = CarouselFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .fast
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.delegate = self
        return cv
    }()

    private let wormPageControl: WormPageControl = {
        let wpc = WormPageControl()
        return wpc
    }()

    // 온보딩과 동일한 리퀴드 글래스 버튼 (SwiftUI 호스팅)
    private lazy var startButtonHost: UIHostingController<PrimaryButtonSwiftUI> = {
        let host = UIHostingController(
            rootView: PrimaryButtonSwiftUI(title: StringLiterals.Book.startButton, height: 56) { [weak self] in
                self?.startButtonTapped()
            }
        )
        host.view.backgroundColor = .clear
        return host
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupActions()
        bookDataSource.configure(with: collectionView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        streakBadge.configure(count: computeStreak())
    }

    /// 연속으로 읽은 날 수 (공용 StreakCalculator로 통합 — 중복 제거)
    private func computeStreak() -> Int {
        (try? readingRepository.fetchCurrentStreak()) ?? 0
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension BookViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - 60
        return CGSize(width: width, height: 300)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePageControl()
    }
}

// MARK: - Private Methods

private extension BookViewController {

    func setupStyle() {
        // 배경은 BaseViewController(.secondary)가 처리
        // 타이틀은 nav 바 말고 콘텐츠(bookTitleLabel)에서 직접 → 스트릭과 같은 선상
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = ""

        wormPageControl.numberOfPages = bookDataSource.items.count
    }

    func setupHierarchy() {
        view.addSubview(bookTitleLabel)
        view.addSubview(collectionView)
        view.addSubview(wormPageControl)
        view.addSubview(streakBadge)
        addChild(startButtonHost)
        view.addSubview(startButtonHost.view)
        startButtonHost.didMove(toParent: self)
    }

    func setupLayout() {
        bookTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        wormPageControl.translatesAutoresizingMaskIntoConstraints = false
        streakBadge.translatesAutoresizingMaskIntoConstraints = false
        startButtonHost.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bookTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            bookTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            streakBadge.centerYAnchor.constraint(equalTo: bookTitleLabel.centerYAnchor),
            streakBadge.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(
                equalTo: bookTitleLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),

            wormPageControl.topAnchor.constraint(
                equalTo: collectionView.bottomAnchor, constant: 20),
            wormPageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),

            startButtonHost.view.topAnchor.constraint(
                equalTo: wormPageControl.bottomAnchor, constant: 30),
            startButtonHost.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 80),
            startButtonHost.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -80),
            startButtonHost.view.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    func updatePageControl() {
        let itemWidth = collectionView.bounds.width - 60
        let pageWidth = itemWidth + 12
        let offsetX = collectionView.contentOffset.x + collectionView.contentInset.left
        let progress = offsetX / pageWidth
        wormPageControl.progress = progress
    }

    func setupActions() {
        // 탭은 startButtonHost의 SwiftUI 클로저가 처리
    }

    @objc func startButtonTapped() {
        coordinator?.showScanner()
    }
}
