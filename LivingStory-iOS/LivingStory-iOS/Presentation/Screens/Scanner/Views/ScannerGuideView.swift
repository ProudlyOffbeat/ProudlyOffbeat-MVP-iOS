//
//  ScannerGuideView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class ScannerGuideView: UIView {

    // MARK: - UI Components

    private let iconImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let imageView = UIImageView(image: UIImage(.barcode)?.withConfiguration(config))
        imageView.tintColor = UIColor(named: "gray10")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.text = StringLiterals.Scanner.guideTitle
        label.font = .body2SemiBold
        label.textColor = UIColor(named: "gray10")
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = DynamicLabel()
        label.text = StringLiterals.Scanner.guideSubtitle
        label.font = .labelRegular
        label.textColor = UIColor(named: "gray30")
        label.numberOfLines = 0
        return label
    }()

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
}

// MARK: - Private Methods

private extension ScannerGuideView {

    func setupHierarchy() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }

    func setupLayout() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: topAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
