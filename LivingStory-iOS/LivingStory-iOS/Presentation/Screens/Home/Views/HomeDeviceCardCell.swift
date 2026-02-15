//
//  HomeDeviceCardCell.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class HomeDeviceCardCell: UICollectionViewCell {

    static let reuseIdentifier = "HomeDeviceCardCell"

    private var cardView: HomeDeviceCardView?

    func configure(with device: DeviceModel) {
        // 기존 카드뷰 제거
        cardView?.removeFromSuperview()

        let newCard = HomeDeviceCardView(deviceType: device.deviceType)
        newCard.configure(with: device)
        newCard.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(newCard)

        NSLayoutConstraint.activate([
            newCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            newCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            newCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            newCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        cardView = newCard
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardView?.removeFromSuperview()
        cardView = nil
    }
}
