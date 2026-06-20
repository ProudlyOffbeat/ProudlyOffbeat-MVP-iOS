//
//  CarouselCell.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class CarouselCell: UICollectionViewCell {

    static let identifier = "CarouselCell"

    // MARK: - UI Components

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    private let tagLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .footnoteRegular
        label.textColor = .gray100
        label.backgroundColor = UIColor(named: "gray10")
        label.clipsToBounds = true
        return label
    }()

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .body2SemiBold
        label.textColor = UIColor(named: "gray10")
        label.numberOfLines = 0
        return label
    }()

    private let illustrationView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }()

    // MARK: - Init

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
}

// MARK: - Public Methods

extension CarouselCell {
    func configure(tag: String, title: String, imageName: String) {
        tagLabel.text = tag
        titleLabel.text = title
        illustrationView.image = UIImage(named: imageName)
    }
}

// MARK: - Private Methods

private extension CarouselCell {

    func setupStyle() {
        contentView.layer.shadowColor = UIColor(named: "gray80")?.cgColor
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 7.5
    }

    func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(tagLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(illustrationView)
    }

    func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        illustrationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            // 태그 (상단 16, 좌측 16)
            tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            tagLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            // 타이틀 (태그 아래 8)
            titleLabel.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            // 일러스트 이미지 (좌우/하단 16pt 패딩)
            illustrationView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            illustrationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            illustrationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
        ])
    }
}
