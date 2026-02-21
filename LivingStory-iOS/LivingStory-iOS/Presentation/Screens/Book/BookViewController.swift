//
//  BookViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class BookViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    private let bookDataSource = BookDataSource()

    // MARK: - UI Components

    private let radialGlowView = RadialGlowView()

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

    private let startButton = PrimaryButton(
        title: StringLiterals.Book.startButton,
        font: .bodyEmphasized,
        backgroundColor: UIColor(named: "gray0"),
        cornerRadius: 28
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupActions()
        bookDataSource.configure(with: collectionView)
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
        view.backgroundColor = .white

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = StringLiterals.Book.title
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.title1Emphasized
        ]

        wormPageControl.numberOfPages = bookDataSource.items.count
    }

    func setupHierarchy() {
        view.addSubview(radialGlowView)
        view.addSubview(collectionView)
        view.addSubview(wormPageControl)
        view.addSubview(startButton)
    }

    func setupLayout() {
        radialGlowView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        wormPageControl.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radialGlowView.widthAnchor.constraint(equalToConstant: 589),
            radialGlowView.heightAnchor.constraint(equalToConstant: 610),
            radialGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            radialGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 42),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),

            wormPageControl.topAnchor.constraint(
                equalTo: collectionView.bottomAnchor, constant: 20),
            wormPageControl.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),

            startButton.topAnchor.constraint(
                equalTo: wormPageControl.bottomAnchor, constant: 30),
            startButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 80),
            startButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -80),
            startButton.heightAnchor.constraint(equalToConstant: 56)
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
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    @objc func startButtonTapped() {
        coordinator?.showScanner()
    }
}
