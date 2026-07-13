//
//  BookIntroCell.swift
//  LivingStory-iOS
//
//  사용법 카루셀의 첫 번째 카드 (How to use naru).
//  배경 #1D262C + 물결(Intro 에셋) + 사용법/How to use/naru + 플로팅 화살표 버튼.
//

import UIKit

final class BookIntroCell: UICollectionViewCell {

    static let identifier = "BookIntroCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x1D262C)   // 1번 카드 배경
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    private let waveImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Intro"))   // 물결
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
        containerView.addSubview(waveImageView)        // 배경(맨 뒤)
        containerView.addSubview(usageLabel)
        containerView.addSubview(howToUseLabel)
        containerView.addSubview(naruLabel)
        containerView.addSubview(arrowButton)
    }

    private func setupLayout() {
        [containerView, waveImageView, usageLabel, howToUseLabel, naruLabel, arrowButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // 물결: 양쪽 딱 붙게 + 바닥에 + 원본 비율 유지(안 잘림, 프레임 강제 X)
            waveImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            waveImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            waveImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),  // 그림 아래 20
            waveImageView.heightAnchor.constraint(equalTo: waveImageView.widthAnchor,
                                                  multiplier: 205.0 / 320.0),   // Intro 비율

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
}
