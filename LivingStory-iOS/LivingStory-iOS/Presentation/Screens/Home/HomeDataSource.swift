//
//  HomeDataSource.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class HomeDataSource {

    // MARK: - Properties

    private var diffableDataSource: UICollectionViewDiffableDataSource<RoomModel, DeviceModel>!

    // MARK: - Public Methods

    func configure(with collectionView: UICollectionView) {
        collectionView.register(
            HomeDeviceCardCell.self,
            forCellWithReuseIdentifier: HomeDeviceCardCell.reuseIdentifier
        )
        collectionView.register(
            RoomHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RoomHeaderView.reuseIdentifier
        )

        diffableDataSource = UICollectionViewDiffableDataSource<RoomModel, DeviceModel>(
            collectionView: collectionView
        ) { collectionView, indexPath, device in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeDeviceCardCell.reuseIdentifier,
                for: indexPath
            ) as? HomeDeviceCardCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: device, index: indexPath.item)
            return cell
        }

        diffableDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RoomHeaderView.reuseIdentifier,
                for: indexPath
            ) as? RoomHeaderView else {
                return UICollectionReusableView()
            }

            let section = self?.diffableDataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.configure(with: section?.name ?? "")
            return header
        }
    }

    func device(at indexPath: IndexPath) -> DeviceModel? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func applySnapshot(for home: HomeModel) {
        var snapshot = NSDiffableDataSourceSnapshot<RoomModel, DeviceModel>()
        for room in home.rooms {
            snapshot.appendSections([room])
            snapshot.appendItems(room.devices, toSection: room)
        }

        // 기존 아이템의 콘텐츠도 갱신 (isOn, percentage 변경 반영)
        let existingItems = diffableDataSource.snapshot().itemIdentifiers
        let itemsToReconfigure = snapshot.itemIdentifiers.filter { existingItems.contains($0) }
        if !itemsToReconfigure.isEmpty {
            snapshot.reconfigureItems(itemsToReconfigure)
        }

        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}
