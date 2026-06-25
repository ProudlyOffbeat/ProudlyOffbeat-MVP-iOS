//
//  StreakBadgeView.swift
//  LivingStory-iOS
//
//  연속 독서일(스트릭) 뱃지 — flame.fill(g30 그라데이션) + 횟수.
//  마이/책읽기 동일 위치에 사용.
//

import UIKit

final class StreakBadgeView: UIView {

    private let flameImageView: UIImageView = {
        let imageView = UIImageView(image: StreakBadgeView.gradientFlame())
        imageView.contentMode = .center
        return imageView
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)   // SemiBold 16
        label.textColor = .white
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [flameImageView, countLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(count: Int) {
        countLabel.text = "\(count)"
    }

    /// flame.fill 심볼을 g30 그라데이션(#BFEE68 → #FFCB24)으로 채운 이미지
    private static func gradientFlame() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        guard let symbol = UIImage(systemName: "flame.fill", withConfiguration: config) else { return nil }

        let size = symbol.size
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            // 심볼 모양으로 알파 확보
            symbol.withTintColor(.black, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(origin: .zero, size: size))
            // 심볼 영역만 그라데이션으로 채움
            ctx.cgContext.setBlendMode(.sourceIn)
            let colors = [UIColor(hex: 0xBFEE68).cgColor, UIColor(hex: 0xFFCB24).cgColor] as CFArray
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: [0, 1]
            ) else { return }
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: size.width / 2, y: 0),           // 위 #BFEE68
                end: CGPoint(x: size.width / 2, y: size.height),   // 아래 #FFCB24
                options: []
            )
        }
        return image.withRenderingMode(.alwaysOriginal)
    }
}
