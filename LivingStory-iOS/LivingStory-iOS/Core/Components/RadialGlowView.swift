//
//  RadialGlowView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class RadialGlowView: UIView {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupGradient()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - Private Methods

private extension RadialGlowView {

    func setupGradient() {
        isUserInteractionEnabled = false

        gradientLayer.type = .radial
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.769, blue: 0.016, alpha: 0.20).cgColor,
            UIColor(red: 1.0, green: 0.769, blue: 0.016, alpha: 0.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)

        layer.addSublayer(gradientLayer)
    }
}
