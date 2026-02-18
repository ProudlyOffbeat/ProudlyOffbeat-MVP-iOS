//
//  BookDataSource.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class BookDataSource: NSObject, UICollectionViewDataSource {

    // MARK: - Properties

    let items: [(tag: String, title: String, imageName: String)] = [
        (StringLiterals.Book.tagUsage, StringLiterals.Book.titleUsage, StringLiterals.Book.imageUsage),
        (StringLiterals.Book.tag01, StringLiterals.Book.title01, StringLiterals.Book.image01),
        (StringLiterals.Book.tag02, StringLiterals.Book.title02, StringLiterals.Book.image02),
        (StringLiterals.Book.tag03, StringLiterals.Book.title03, StringLiterals.Book.image03),
        (StringLiterals.Book.tag04, StringLiterals.Book.title04, StringLiterals.Book.image04)
    ]

    // MARK: - Public Methods

    func configure(with collectionView: UICollectionView) {
        collectionView.dataSource = self
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.identifier)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CarouselCell.identifier,
            for: indexPath
        ) as? CarouselCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        cell.configure(tag: item.tag, title: item.title, imageName: item.imageName)
        return cell
    }
}
