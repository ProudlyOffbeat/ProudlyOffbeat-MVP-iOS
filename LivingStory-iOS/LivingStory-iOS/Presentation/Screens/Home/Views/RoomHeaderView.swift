//
//  RoomHeaderView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class RoomHeaderView: UICollectionReusableView {

    static let reuseIdentifier = "RoomHeaderView"

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .headlineRegular
        label.textColor = UIColor(named: "gray10")
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with title: String) {
        titleLabel.text = title
    }
}

private extension RoomHeaderView {

    func setupStyle() {
        backgroundColor = .clear
    }

    func setupHierarchy() {
        addSubview(titleLabel)
    }

    func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])
    }
}
