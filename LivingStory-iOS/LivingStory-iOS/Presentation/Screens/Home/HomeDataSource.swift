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

    /// 화면이 그리는 단일 진실(source of truth). 옵티미스틱 pending 상태까지 여기 담긴다.
    /// (DeviceModel이 id로만 Hashable이라, 필드가 바뀐 값을 반영하려면 스냅샷을 이 배열로 새로 만들어야 한다.)
    private var rooms: [RoomModel] = []

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

    /// HomeKit이 보고한 실제 상태로 갱신. 쓰기 진행 중(pending)인 기기는 옵티미스틱 상태를 보존한다.
    func applySnapshot(for home: HomeModel) {
        let oldById = currentDevicesById()
        var changed: Set<UUID> = []

        rooms = home.rooms.map { room in
            var room = room
            room.devices = room.devices.map { fresh in
                var device = fresh   // authoritative isOn, pendingIsOn == nil
                if let old = oldById[fresh.id], let pending = old.pendingIsOn {
                    // 아직 응답 대기 중: 실제값이 목표에 도달했으면 확정, 아니면 옵티미스틱 유지
                    device.pendingIsOn = (fresh.isOn == pending) ? nil : pending
                }
                if let old = oldById[fresh.id], hasDisplayChange(old, device) {
                    changed.insert(fresh.id)
                }
                return device
            }
            return room
        }

        rebuild(reconfiguring: changed)
    }

    // MARK: - Optimistic Toggle

    /// 탭 즉시 호출 — 모델에 목표값을 반영해 셀을 곧바로 목표 상태로 그린다.
    func beginToggle(deviceId: UUID, target: Bool) {
        mutateDevice(deviceId) { $0.pendingIsOn = target }
    }

    /// 쓰기 응답 후 호출 — 성공하면 실제값을 목표로 확정, 실패하면 pending을 지워 이전 상태로 롤백.
    func resolveToggle(deviceId: UUID, success: Bool) {
        mutateDevice(deviceId) { device in
            if success, let target = device.pendingIsOn {
                device.isOn = target
            }
            device.pendingIsOn = nil
        }
    }
}

// MARK: - Private

private extension HomeDataSource {

    func currentDevicesById() -> [UUID: DeviceModel] {
        Dictionary(
            rooms.flatMap(\.devices).map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
    }

    /// 셀이 다시 그려져야 할 만큼 변화가 있는지 (전원 표시/상태문구/pending 스피너).
    func hasDisplayChange(_ old: DeviceModel, _ new: DeviceModel) -> Bool {
        old.displayIsOn != new.displayIsOn
            || old.percentage != new.percentage
            || old.isPending != new.isPending
    }

    /// 특정 기기 하나만 바꾸고, 그 셀만 reconfigure.
    func mutateDevice(_ deviceId: UUID, _ transform: (inout DeviceModel) -> Void) {
        var didChange = false
        for roomIndex in rooms.indices {
            guard let deviceIndex = rooms[roomIndex].devices.firstIndex(where: { $0.id == deviceId })
            else { continue }
            let before = rooms[roomIndex].devices[deviceIndex]
            transform(&rooms[roomIndex].devices[deviceIndex])
            didChange = hasDisplayChange(before, rooms[roomIndex].devices[deviceIndex])
            break
        }
        if didChange {
            rebuild(reconfiguring: [deviceId])
        }
    }

    /// `rooms`(단일 진실)로 스냅샷을 새로 만들어 적용한다.
    /// id-only Hashable이라 새 스냅샷을 만들어야 바뀐 필드값이 셀에 전달된다.
    func rebuild(reconfiguring ids: Set<UUID>) {
        var snapshot = NSDiffableDataSourceSnapshot<RoomModel, DeviceModel>()
        for room in rooms {
            snapshot.appendSections([room])
            snapshot.appendItems(room.devices, toSection: room)
        }
        let toReconfigure = snapshot.itemIdentifiers.filter { ids.contains($0.id) }
        if !toReconfigure.isEmpty {
            snapshot.reconfigureItems(toReconfigure)
        }
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}
