//
//  HomeViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    private let homeKitManager = HomeKitManager()
    private var homes: [HomeModel] = []
    private var currentHome: HomeModel?

    private var dataSource: UICollectionViewDiffableDataSource<RoomModel, DeviceModel>!

    private let homeMenuButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        button.setImage(UIImage(.ellipsis)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "gray10")
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private lazy var roomCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private let radialGlowView = RadialGlowView()

    private let emptyStateView: HomeEmptyStateView = {
        let view = HomeEmptyStateView()
        view.isHidden = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHomeNavigation()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupCollectionView()
        setupEmptyStateActions()
        bindHomeKit()
    }
}

// MARK: - Setup

private extension HomeViewController {

    func setupHomeNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.title1Emphasized
        ]

        let moreBarButton = UIBarButtonItem(customView: homeMenuButton)
        navigationItem.rightBarButtonItem = moreBarButton
    }

    func setupStyle() {
        view.backgroundColor = .systemBackground
        roomCollectionView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
    }

    func setupHierarchy() {
        view.addSubview(radialGlowView)
        view.addSubview(roomCollectionView)
        view.addSubview(emptyStateView)
    }

    func setupLayout() {
        radialGlowView.translatesAutoresizingMaskIntoConstraints = false
        roomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radialGlowView.widthAnchor.constraint(equalToConstant: 589),
            radialGlowView.heightAnchor.constraint(equalToConstant: 610),
            radialGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            radialGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            roomCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            roomCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            roomCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            roomCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 142 ),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupCollectionView() {
        roomCollectionView.register(
            HomeDeviceCardCell.self,
            forCellWithReuseIdentifier: HomeDeviceCardCell.reuseIdentifier
        )
        roomCollectionView.register(
            RoomHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: RoomHeaderView.reuseIdentifier
        )

        dataSource = UICollectionViewDiffableDataSource<RoomModel, DeviceModel>(
            collectionView: roomCollectionView
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

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RoomHeaderView.reuseIdentifier,
                for: indexPath
            ) as? RoomHeaderView else {
                return UICollectionReusableView()
            }

            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            header.configure(with: section.name)
            return header
        }
    }

    func setupEmptyStateActions() {
        emptyStateView.onButtonTapped = { [weak self] in
            self?.openSettings()
        }
    }

    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(122)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(122)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: 2
            )
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 20,
                bottom: 32,
                trailing: 20
            )
            section.interGroupSpacing = 12

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(32)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

// MARK: - HomeKit Binding

private extension HomeViewController {

    func bindHomeKit() {
        homeKitManager.onHomesUpdated = { [weak self] homes in
            guard let self else { return }
            self.homes = homes

            if let first = homes.first {
                self.currentHome = first
                self.updateUI(for: first.state)
            } else {
                self.currentHome = nil
                self.updateUI(for: .noDevices)
            }
        }

        homeKitManager.onPermissionDenied = { [weak self] in
            self?.homes = []
            self?.currentHome = nil
            self?.updateUI(for: .permissionsRequired)
        }
    }
}

// MARK: - State Management

private extension HomeViewController {

    func updateUI(for state: HomeState) {
        updateHomeMenu()

        switch state {
        case .normal:
            emptyStateView.isHidden = true
            roomCollectionView.isHidden = false
            navigationItem.rightBarButtonItem?.isHidden = false
            navigationItem.title = currentHome?.name
            applySnapshot()

        case .permissionsRequired:
            emptyStateView.isHidden = false
            roomCollectionView.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
            navigationItem.title = StringLiterals.Home.permissionTitle
            emptyStateView.configure(for: .permissionsRequired)

        case .noDevices:
            emptyStateView.isHidden = false
            roomCollectionView.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = false
            navigationItem.title = StringLiterals.Home.noDevicesTitle
            emptyStateView.configure(for: .noDevices)
        }
    }

    func updateHomeMenu() {
        guard !homes.isEmpty else {
            homeMenuButton.menu = UIMenu(
                title: StringLiterals.Home.menuTitle,
                children: [
                    UIAction(
                        title: StringLiterals.Home.noDevicesSubtitle,
                        attributes: .disabled
                    ) { _ in }
                ]
            )
            return
        }

        let actions = homes.map { home in
            let isSelected = home.id == currentHome?.id
            let action = UIAction(
                title: home.name,
                image: isSelected ? UIImage(.checkmark) : nil
            ) { [weak self] _ in
                self?.selectHome(home)
            }
            return action
        }

        homeMenuButton.menu = UIMenu(
            title: StringLiterals.Home.menuTitle,
            children: actions
        )
    }

    func selectHome(_ home: HomeModel) {
        currentHome = home
        updateUI(for: home.state)
    }

    func applySnapshot() {
        guard let home = currentHome else { return }

        var snapshot = NSDiffableDataSourceSnapshot<RoomModel, DeviceModel>()
        for room in home.rooms {
            snapshot.appendSections([room])
            snapshot.appendItems(room.devices, toSection: room)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Preview

#if DEBUG
extension HomeViewController {

    func configurePreview(for state: HomeState) {
        homeKitManager.onHomesUpdated = nil
        homeKitManager.onPermissionDenied = nil

        let mockHomes = Self.makeMockHomes()

        switch state {
        case .normal:
            homes = mockHomes
            currentHome = mockHomes[0]

        case .noDevices:
            homes = mockHomes
            currentHome = mockHomes[1]

        case .permissionsRequired:
            homes = []
            currentHome = nil
        }

        updateUI(for: state)
    }

    private static func makeMockHomes() -> [HomeModel] {
        [
            HomeModel(
                id: UUID(),
                name: "집 1",
                state: .normal,
                rooms: [
                    RoomModel(name: "거실", id: UUID(), devices: [
                        DeviceModel(name: "거실 조명", id: UUID(), isOn: true, deviceType: .light, percentage: 80),
                        DeviceModel(name: "거실 스피커", id: UUID(), isOn: true, deviceType: .speaker, percentage: 50)
                    ]),
                    RoomModel(name: "침실", id: UUID(), devices: [
                        DeviceModel(name: "침실 조명", id: UUID(), isOn: false, deviceType: .light, percentage: nil),
                        DeviceModel(name: "침실 스피커", id: UUID(), isOn: true, deviceType: .speaker, percentage: 30)
                    ]),
                    RoomModel(name: "아이 방", id: UUID(), devices: [
                        DeviceModel(name: "무드등", id: UUID(), isOn: true, deviceType: .light, percentage: 40),
                        DeviceModel(name: "동화 스피커", id: UUID(), isOn: false, deviceType: .speaker, percentage: nil)
                    ])
                ]
            ),
            HomeModel(
                id: UUID(),
                name: "집 2",
                state: .noDevices,
                rooms: []
            ),
            HomeModel(
                id: UUID(),
                name: "별장",
                state: .normal,
                rooms: [
                    RoomModel(name: "거실", id: UUID(), devices: [
                        DeviceModel(name: "스탠드", id: UUID(), isOn: true, deviceType: .light, percentage: 60)
                    ])
                ]
            )
        ]
    }
}

#Preview("기기 있음") {
    let vc = HomeViewController()
    let nav = UINavigationController(rootViewController: vc)
    vc.loadViewIfNeeded()
    vc.configurePreview(for: .normal)
    return nav
}

#Preview("권한 필요") {
    let vc = HomeViewController()
    let nav = UINavigationController(rootViewController: vc)
    vc.loadViewIfNeeded()
    vc.configurePreview(for: .permissionsRequired)
    return nav
}

#Preview("기기 없음") {
    let vc = HomeViewController()
    let nav = UINavigationController(rootViewController: vc)
    vc.loadViewIfNeeded()
    vc.configurePreview(for: .noDevices)
    return nav
}
#endif
