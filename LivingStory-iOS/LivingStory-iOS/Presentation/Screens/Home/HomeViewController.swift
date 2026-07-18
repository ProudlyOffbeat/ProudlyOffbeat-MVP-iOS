//
//  HomeViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class HomeViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    // 실제(HomeKitManager) 또는 목업(MockHomeProvider) — 실행 인자로 결정 (DEBUG)
    private let homeProvider: HomeDataProviding = HomeProviderFactory.make()
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
        button.tintColor = .white       // 흰색 아이콘, 배경 클리어
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let homeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .title1SemiBold
        label.textColor = .white
        return label
    }()

    private lazy var roomCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.delaysContentTouches = false   // 탭 즉시 인식 (시스템 ~100ms 지연 제거)
        return collectionView
    }()

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
        Task { await homeProvider.refreshAllCharacteristics() }
    }

    @objc private func handleWillEnterForeground() {
        Task { await homeProvider.refreshAllCharacteristics() }
    }
}

// MARK: - Setup

private extension HomeViewController {

    func setupHomeNavigation() {
        // 타이틀은 nav 바 말고 콘텐츠(homeTitleLabel)에서 직접 그림 → async 타이밍 버그 원천 제거
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = ""

        let moreBarButton = UIBarButtonItem(customView: homeMenuButton)
        navigationItem.rightBarButtonItem = moreBarButton
    }

    func setupStyle() {
        // 배경은 BaseViewController(.secondary)가 처리
        // 큰 타이틀 추적을 위해 수동 contentInset.top 제거 (시스템이 nav inset 처리)
    }

    func setupHierarchy() {
        view.addSubview(homeTitleLabel)
        view.addSubview(roomCollectionView)
        view.addSubview(emptyStateView)
    }

    func setupLayout() {
        homeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        roomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            homeTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            homeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            // 타이틀 ↔ 첫 룸 이름 = 38 + 섹션 top inset 8 = 46
            roomCollectionView.topAnchor.constraint(equalTo: homeTitleLabel.bottomAnchor, constant: 38),
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

        // 진행 중이면 재탭 무시 (응답 받을 때까지)
        guard !togglingDeviceIds.contains(device.id) else { return }
        togglingDeviceIds.insert(device.id)

        // 목표값 = 현재 화면에 그려진 상태의 반대 (옵티미스틱 상태 기준)
        let target = !device.displayIsOn
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 옵티미스틱: 모델(단일 진실)에 목표값 반영 → 셀은 자동으로 목표 상태 + "적용 중" 표시.
        // 셀이 화면에 있든 없든(오프스크린) 모델 기준이라 항상 일관되게 반영된다.
        homeDataSource.beginToggle(deviceId: device.id, target: target)

        Task { [weak self] in
            guard let self else { return }
            var success = false
            do {
                try await self.homeProvider.setPower(target, for: device.id)
                success = true
            } catch {
                print("[HomeKit] 전원 토글 실패: \(error.localizedDescription)")
            }

            await MainActor.run {
                // 성공 → 목표값으로 확정, 실패 → 이전 상태로 롤백 (둘 다 pending 해제)
                self.homeDataSource.resolveToggle(deviceId: device.id, success: success)
                self.togglingDeviceIds.remove(device.id)
                if !success {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }

            // 실패 시 실제 기기 상태로 재동기화 (타임아웃이었는데 실제로는 켜졌을 수도 있으니)
            if !success {
                await self.homeProvider.refreshAllCharacteristics()
            }
        }
    }
}

// MARK: - HomeKit Binding

private extension HomeViewController {

    func bindHomeKit() {
        homeProvider.onHomesUpdated = { [weak self] homes in
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

        homeProvider.onPermissionDenied = { [weak self] in
            self?.homes = []
            self?.currentHome = nil
            self?.updateUI(for: .permissionsRequired)
        }

        homeProvider.checkInitialStatus()
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
            homeTitleLabel.isHidden = false
            navigationItem.rightBarButtonItem?.isHidden = false
            homeTitleLabel.text = home.name
            homeDataSource.applySnapshot(for: home)

        case .permissionsRequired:
            emptyStateView.isHidden = false
            roomCollectionView.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = true
            homeTitleLabel.text = StringLiterals.Home.permissionTitle
            emptyStateView.configure(for: .permissionsRequired)

        case .noDevices:
            emptyStateView.isHidden = false
            roomCollectionView.isHidden = true
            navigationItem.rightBarButtonItem?.isHidden = false
            homeTitleLabel.text = StringLiterals.Home.noDevicesTitle
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
