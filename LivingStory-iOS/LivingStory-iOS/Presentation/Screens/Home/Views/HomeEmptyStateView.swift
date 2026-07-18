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
        imageView.tintColor = .white   // 집 아이콘 = 흰색
        let config = UIImage.SymbolConfiguration(pointSize: 66, weight: .regular)
        imageView.preferredSymbolConfiguration = config
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .body1SemiBold
        label.textColor = .white                                     // 타이틀 = 흰색 (Labels/Primary)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .labelRegular
        label.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.6)  // 서브타이틀 = 세컨더리 그레이 (바탕과 구분)
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
            // Figma 269-4973 — 콘텐츠를 화면 중앙에 동적 배치(상단 고정 X), 살짝 위로.
            // 기기별 화면 높이에 맞춰 자동 이동. spacing(22/8)·색상·버튼은 유지.
            contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100)
        ])
    }

    func setupActions() {
        actionButton.addAction(UIAction { [weak self] _ in
            self?.onButtonTapped?()
        }, for: .touchUpInside)
    }
}
