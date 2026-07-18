//
//  HomeDeviceCardCell.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class HomeDeviceCardCell: UICollectionViewCell {

    static let reuseIdentifier = "HomeDeviceCardCell"

    private let cardView = HomeDeviceCardView(deviceType: .light)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardView.resetForReuse()   // 재사용 셀에서 켜짐 애니메이션이 잘못 튀지 않도록 초기화
    }
}

// MARK: - Public Methods

extension HomeDeviceCardCell {
    func configure(with device: DeviceModel, index: Int) {
        cardView.configure(with: device, index: index)
    }
}

// MARK: - Private Methods

private extension HomeDeviceCardCell {

    func setupHierarchy() {
        contentView.addSubview(cardView)
    }

    func setupLayout() {
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
