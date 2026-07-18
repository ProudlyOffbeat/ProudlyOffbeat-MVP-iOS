//
//  BookIntroCell.swift
//  LivingStory-iOS
//
//  사용법 카루셀의 첫 번째 카드 (How to use naru).
//  배경 화이트 16%(Figma 897:3214) + 물결(벡터 897:3218) + 사용법/How to use/naru + 플로팅 화살표 버튼.
//

import UIKit

final class BookIntroCell: UICollectionViewCell {

    static let identifier = "BookIntroCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.16)   // Figma 카드 fill = 화이트 16%
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    // Figma 897:3215 Subtract — 카드 대부분을 검정 23%로 덮되 웨이브 밴드만 밝게 남긴다 (배경 위·웨이브 아래)
    private let subtractView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    private let subtractLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.black.withAlphaComponent(0.23).cgColor
        return layer
    }()

    // Figma 897:3218 웨이브 = Intro 에셋 (viewBox 320×205, 양끝이 카드 밖으로 블리드 → 지렁이 캡 안 보임)
    private let waveView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Intro"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let usageLabel: UILabel = {
        let label = DynamicLabel()
        label.text = StringLiterals.Book.tagUsage          // "사용법"
        label.font = .calloutRegular
        label.textColor = .secondaryLabel
        return label
    }()

    private let howToUseLabel: UILabel = {
        let label = UILabel()
        label.text = "How to use"
        label.font = UIFont(name: "GoogleSansFlex36pt-Medium", size: 41)
            ?? .systemFont(ofSize: 41, weight: .medium)
        label.textColor = .white
        return label
    }()

    private let naruLabel: UILabel = {
        let label = UILabel()
        let font = UIFont(name: "PlaywriteUSTrad-Regular", size: 38)
            ?? .systemFont(ofSize: 38)
        label.attributedText = NSAttributedString(string: "naru", attributes: [
            .font: font,
            .foregroundColor: UIColor(named: "yellow60") ?? .systemYellow,
            .kern: -0.76   // Letter spacing -2% (38 × -0.02)
        ])
        return label
    }()

    private let arrowButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(
            systemName: "arrow.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        )
        config.baseForegroundColor = .white
        config.background.backgroundColor = UIColor(hex: 0x161717)
        config.cornerStyle = .capsule       // 45×45 → 완전한 원
        return UIButton(configuration: config)
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

    // MARK: - Setup

    private func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(subtractView)    // 배경 위 (Figma Subtract)
        subtractView.layer.addSublayer(subtractLayer)
        containerView.addSubview(waveView)        // Subtract 위, 나머지 뒤
        containerView.addSubview(usageLabel)
        containerView.addSubview(howToUseLabel)
        containerView.addSubview(naruLabel)
        containerView.addSubview(arrowButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Figma Subtract 셰이프를 카드 크기에 맞게 스케일
        subtractLayer.frame = subtractView.bounds
        subtractLayer.path = Self.subtractPath(in: subtractView.bounds)
    }

    private func setupLayout() {
        [containerView, subtractView, waveView, usageLabel, howToUseLabel, naruLabel, arrowButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            subtractView.topAnchor.constraint(equalTo: containerView.topAnchor),
            subtractView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            subtractView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            subtractView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // 물결: 양쪽 딱 붙게 + 바닥에서 20 + Intro 에셋 비율 320×205
            waveView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            waveView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            waveView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            waveView.heightAnchor.constraint(equalTo: waveView.widthAnchor,
                                                  multiplier: 205.0 / 320.0),

            // 사용법: leading 28, top 32
            usageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            usageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),

            // How to use: leading 28
            howToUseLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            howToUseLabel.topAnchor.constraint(equalTo: usageLabel.bottomAnchor, constant: 24),

            // naru: leading 28
            naruLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            naruLabel.topAnchor.constraint(equalTo: howToUseLabel.bottomAnchor, constant: -8),  // 좀 더 붙게

            // 플로팅 버튼: 원 45×45, 우측 22.5, How to use와 세로 중앙 정렬
            arrowButton.widthAnchor.constraint(equalToConstant: 45),
            arrowButton.heightAnchor.constraint(equalToConstant: 45),
            arrowButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22.5),
            arrowButton.centerYAnchor.constraint(equalTo: howToUseLabel.centerYAnchor),
        ])
    }

    /// Figma 897:3215 Subtract 셰이프 (viewBox 320×274, 카드 300 높이 기준 상단 정렬).
    /// 카드를 검정 23%로 덮되 하단 물결 밴드는 남겨 웨이브가 더 밝게 도드라진다.
    private static func subtractPath(in rect: CGRect) -> CGPath {
        let sx = rect.width / 320
        let sy = rect.height / 300
        let p = UIBezierPath()
        p.move(to: CGPoint(x: 320, y: 86))
        p.addLine(to: CGPoint(x: 296.5, y: 153.5))
        p.addLine(to: CGPoint(x: 285, y: 168.5))
        p.addLine(to: CGPoint(x: 271.5, y: 222))
        p.addLine(to: CGPoint(x: 258, y: 245))
        p.addLine(to: CGPoint(x: 234, y: 259.5))
        p.addLine(to: CGPoint(x: 206.5, y: 274))
        p.addLine(to: CGPoint(x: 174, y: 274))
        p.addLine(to: CGPoint(x: 123.5, y: 254.5))
        p.addLine(to: CGPoint(x: 40.5, y: 222))
        p.addLine(to: CGPoint(x: 0, y: 233))
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 320, y: 0))
        p.addLine(to: CGPoint(x: 320, y: 86))
        p.close()
        p.apply(CGAffineTransform(scaleX: sx, y: sy))
        return p.cgPath
    }
}
