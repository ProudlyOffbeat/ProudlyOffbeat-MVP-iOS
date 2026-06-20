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
    private let homeDataSource = HomeDataSource()
    private var homes: [HomeModel] = []
    private var currentHome: HomeModel?
    private var currentEmptyState: HomeState = .noDevices

    /// 토글 진행 중인 디바이스 ID — 재탭 차단 (HomeKit 응답 받기 전까지)
    private var togglingDeviceIds: Set<UUID> = []

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
        collectionView.delaysContentTouches = false   // 탭 즉시 인식 (시스템 ~100ms 지연 제거)
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
        homeDataSource.configure(with: roomCollectionView)
        roomCollectionView.delegate = self
        setupEmptyStateActions()
        bindHomeKit()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await homeKitManager.refreshAllCharacteristics() }
    }

    @objc private func handleWillEnterForeground() {
        Task { await homeKitManager.refreshAllCharacteristics() }
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

    func setupEmptyStateActions() {
        emptyStateView.onButtonTapped = { [weak self] in
            guard let self else { return }
            switch self.currentEmptyState {
            case .permissionsRequired:
                self.openSettings()
            case .noDevices:
                self.openHomeApp()
            case .normal:
                break
            }
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

// MARK: - UICollectionViewDelegate (기기 탭 토글)

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let device = homeDataSource.device(at: indexPath) else { return }

        // tapped 플래그 — 진행 중이면 재탭 무시
        guard !togglingDeviceIds.contains(device.id) else { return }
        togglingDeviceIds.insert(device.id)

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 옵티미스틱 UI: 셀 즉시 토글
        if let cell = collectionView.cellForItem(at: indexPath) as? HomeDeviceCardCell {
            var newDevice = device
            newDevice.isOn.toggle()
            cell.configure(with: newDevice)
        }

        Task { [weak self] in
            defer {
                Task { @MainActor in
                    self?.togglingDeviceIds.remove(device.id)
                }
            }
            do {
                try await self?.homeKitManager.togglePower(for: device.id)
            } catch {
                print("[HomeKit] 전원 토글 실패: \(error.localizedDescription)")
                // 실패 시 cell 을 실제 상태로 즉시 복원
                await MainActor.run { [weak self] in
                    guard let self,
                          let cell = collectionView.cellForItem(at: indexPath) as? HomeDeviceCardCell,
                          let actualDevice = self.homeDataSource.device(at: indexPath) else { return }
                    cell.configure(with: actualDevice)
                }
                await self?.homeKitManager.refreshAllCharacteristics()
            }
        }
    }
}

// MARK: - HomeKit Binding

private extension HomeViewController {

    func bindHomeKit() {
        homeKitManager.onHomesUpdated = { [weak self] homes in
            guard let self else { return }
            self.homes = homes

            // 현재 선택된 집 유지 (실시간 업데이트 시 리셋 방지)
            if let selectedId = self.currentHome?.id,
               let updated = homes.first(where: { $0.id == selectedId }) {
                self.currentHome = updated
                self.updateUI(for: updated.state)
            } else if let first = homes.first {
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

        homeKitManager.checkInitialStatus()
    }
}

// MARK: - State Management

private extension HomeViewController {

    func updateUI(for state: HomeState) {
        currentEmptyState = state
        updateHomeMenu()

        switch state {
        case .normal:
            guard let home = currentHome else { return }
            emptyStateView.isHidden = true
            roomCollectionView.isHidden = false
            navigationItem.rightBarButtonItem?.isHidden = false
            navigationItem.title = home.name
            homeDataSource.applySnapshot(for: home)

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

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func openHomeApp() {
        guard let url = URL(string: "com.apple.home://"),
              UIApplication.shared.canOpenURL(url) else {
            openSettings()
            return
        }
        UIApplication.shared.open(url)
    }
}
