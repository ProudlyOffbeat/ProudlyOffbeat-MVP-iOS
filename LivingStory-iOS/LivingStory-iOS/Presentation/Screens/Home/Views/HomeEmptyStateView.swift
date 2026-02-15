//
//  HomeEmptyStateView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class HomeEmptyStateView: UIView {

    // MARK: - Properties

    var onButtonTapped: (() -> Void)?

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "gray10")
        let config = UIImage.SymbolConfiguration(pointSize: 66, weight: .regular)
        imageView.preferredSymbolConfiguration = config
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .title3Emphasized
        label.textColor = UIColor(named: "gray10")
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .subhaedlineRegular
        label.textColor = UIColor(named: "gray40")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let actionButton = DarkRoundedButton(title: StringLiterals.Home.permissionButton)

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupHierarchy()
        setupLayout()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension HomeEmptyStateView {

    func configure(for state: HomeState) {
        switch state {
        case .permissionsRequired:
            iconImageView.image = UIImage(systemName: "house.badge.exclamationmark")
            titleLabel.text = StringLiterals.Home.permissionTitle
            subtitleLabel.text = StringLiterals.Home.permissionSubtitle
            actionButton.setTitle(StringLiterals.Home.permissionButton, for: .normal)

        case .noDevices:
            iconImageView.image = UIImage(systemName: "house.slash")
            titleLabel.text = StringLiterals.Home.noDevicesTitle
            subtitleLabel.text = StringLiterals.Home.noDevicesSubtitle
            actionButton.setTitle(StringLiterals.Home.noDevicesButton, for: .normal)

        case .normal:
            break
        }
    }
}

// MARK: - Private Methods

private extension HomeEmptyStateView {

    func setupHierarchy() {
        addSubview(contentStackView)

        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(actionButton)

        contentStackView.setCustomSpacing(22, after: iconImageView)
        contentStackView.setCustomSpacing(8, after: titleLabel)
        contentStackView.setCustomSpacing(32, after: subtitleLabel)
        contentStackView.setCustomSpacing(0, after: actionButton)
    }

    func setupLayout() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    func setupActions() {
        actionButton.addAction(UIAction { [weak self] _ in
            self?.onButtonTapped?()
        }, for: .touchUpInside)
    }
}
