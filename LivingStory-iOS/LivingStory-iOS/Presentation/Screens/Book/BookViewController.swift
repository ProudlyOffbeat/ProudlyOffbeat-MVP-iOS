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

    private let carouselItems: [(tag: String, title: String, imageName: String)] = [
        (StringLiterals.Book.tagUsage, StringLiterals.Book.titleUsage, StringLiterals.Book.imageUsage),
        (StringLiterals.Book.tag01, StringLiterals.Book.title01, StringLiterals.Book.image01),
        (StringLiterals.Book.tag02, StringLiterals.Book.title02, StringLiterals.Book.image02),
        (StringLiterals.Book.tag03, StringLiterals.Book.title03, StringLiterals.Book.image03),
        (StringLiterals.Book.tag04, StringLiterals.Book.title04, StringLiterals.Book.image04)
    ]

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
        cv.dataSource = self
        cv.delegate = self
        cv.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
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
    }
}

// MARK: - UICollectionViewDataSource

extension BookViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        carouselItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CarouselCell.identifier,
            for: indexPath
        ) as? CarouselCell else {
            return UICollectionViewCell()
        }
        let item = carouselItems[indexPath.item]
        cell.configure(tag: item.tag, title: item.title, imageName: item.imageName)
        return cell
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

        wormPageControl.numberOfPages = carouselItems.count
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
        let pageWidth = itemWidth + 12 // item width + minimumLineSpacing
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

// MARK: - Preview

#Preview {
    UINavigationController(rootViewController: BookViewController())
}
