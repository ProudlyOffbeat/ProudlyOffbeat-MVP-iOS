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
            cell.configure(with: device)
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

        // 값이 실제로 바뀐 디바이스만 reconfigure (옵티미스틱 UI 자동 보호)
        let oldItemsById = Dictionary(
            diffableDataSource.snapshot().itemIdentifiers.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let itemsToReconfigure = snapshot.itemIdentifiers.filter { newItem in
            guard let oldItem = oldItemsById[newItem.id] else { return false }
            return oldItem.isOn != newItem.isOn || oldItem.percentage != newItem.percentage
        }
        if !itemsToReconfigure.isEmpty {
            snapshot.reconfigureItems(itemsToReconfigure)
        }

        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}
