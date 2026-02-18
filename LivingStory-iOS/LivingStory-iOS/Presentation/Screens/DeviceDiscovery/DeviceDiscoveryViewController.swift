//
//  DeviceDiscoveryViewController.swift
//  LivingStory-iOS
//
//  🧑‍💻 담당: 데미안 (UIKit)
//
//  📚 HomeKit 기기 검색 (나중에 구현)
//  - HMHomeManager 사용
//  - 발견된 기기 목록 표시
//

import UIKit

final class DeviceDiscoveryViewController: UIViewController {

    weak var coordinator: AppCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "gray100")
        title = "기기 검색"
    }

    private func setupLayout() {
        // TODO: UITableView 또는 UICollectionView
    }

    private func setupActions() {
        // TODO: 기기 선택 시 처리
    }
}

