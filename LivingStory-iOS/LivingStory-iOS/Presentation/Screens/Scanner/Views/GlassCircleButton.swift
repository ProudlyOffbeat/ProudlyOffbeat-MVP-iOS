//
//  GlassCircleButton.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class GlassCircleButton: UIControl {

    // MARK: - Properties

    var isActive: Bool = false {
        didSet { updateAppearance() }
    }

    private let activeColor: UIColor
    private let iconSymbol: SymbolLiterals
    private let activeIconSymbol: SymbolLiterals?

    // MARK: - UI Components

    private let blurView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.isUserInteractionEnabled = false
        blur.clipsToBounds = true
        blur.layer.borderWidth = 1
        blur.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return blur
    }()

    private let tintOverlay: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    // MARK: - Init

    /// - Parameters:
    ///   - icon: 기본 상태 SF Symbol
    ///   - activeIcon: 활성 상태 SF Symbol (nil이면 기본 아이콘 유지)
    ///   - activeColor: 활성 상태 배경 틴트 색상 (기본: blue0)
    ///   - size: 버튼 크기 (기본: 50)
    init(
        icon: SymbolLiterals,
        activeIcon: SymbolLiterals? = nil,
        activeColor: UIColor = UIColor(named: "blue0") ?? .systemBlue,
        size: CGFloat = 50
    ) {
        self.iconSymbol = icon
        self.activeIconSymbol = activeIcon
        self.activeColor = activeColor
        super.init(frame: .zero)
        setupView(size: size)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.width / 2
        blurView.layer.cornerRadius = radius
        tintOverlay.layer.cornerRadius = radius
    }
}

// MARK: - Private Methods

private extension GlassCircleButton {

    func setupView(size: CGFloat) {
        let config = UIImage.SymbolConfiguration(pointSize: size * 0.4, weight: .medium)
        iconImageView.image = UIImage(iconSymbol)?.withConfiguration(config)

        tintOverlay.backgroundColor = activeColor

        addSubview(blurView)
        addSubview(tintOverlay)
        addSubview(iconImageView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        tintOverlay.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),

            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            tintOverlay.topAnchor.constraint(equalTo: topAnchor),
            tintOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            tintOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            tintOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func updateAppearance() {
        let config = UIImage.SymbolConfiguration(pointSize: bounds.width * 0.4, weight: .medium)
        let symbol = isActive ? (activeIconSymbol ?? iconSymbol) : iconSymbol
        iconImageView.image = UIImage(symbol)?.withConfiguration(config)

        UIView.animate(withDuration: 0.25) {
            self.tintOverlay.alpha = self.isActive ? 1.0 : 0.0
            self.blurView.layer.borderColor = self.isActive
                ? self.activeColor.withAlphaComponent(0.4).cgColor
                : UIColor.white.withAlphaComponent(0.2).cgColor
        }
    }
}
