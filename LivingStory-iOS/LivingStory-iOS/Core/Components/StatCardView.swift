//
//  StatCardView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📊 통계 카드 컴포넌트 (UIKit)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  SwiftUI 버전: StatCard (StatisticsView.swift 내 정의)
//
//  사용법:
//  ```swift
//  let card = StatCardView()
//  card.configure(icon: .calendar, title: "이번 달 읽은 책 수", value: "3권")
//  ```
//

import UIKit

// MARK: - UIKit Version

final class StatCardView: UIView {

    // MARK: - UI Components

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadlineRegular
        label.textColor = .label
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadlineEmphasized
        label.textColor = .label
        return label
    }()

    private let contentStack = UIStackView()
    private var isLayoutReady = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    /// 세로 레이아웃 (좁은 카드): 아이콘 + 세로(타이틀, 값)
    func configure(icon: SymbolLiterals, title: String, value: String) {
        if !isLayoutReady {
            setupNarrowLayout()
            isLayoutReady = true
        }
        iconImageView.image = UIImage(icon)
        titleLabel.text = title
        valueLabel.text = value
    }

    /// 가로 레이아웃 (넓은 카드): 아이콘 + 타이틀 ... 값
    func configureWide(icon: SymbolLiterals, title: String, value: String) {
        if !isLayoutReady {
            setupWideLayout()
            isLayoutReady = true
        }
        iconImageView.image = UIImage(icon)
        titleLabel.text = title
        valueLabel.text = value
    }
}

// MARK: - Setup

private extension StatCardView {

    func setupStyle() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    /// 좁은 카드: 각 요소 개별 배치
    func setupNarrowLayout() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 아이콘
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),    // 왼쪽
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),             // 위

            // 타이틀 (예: "총 읽은 책 수")
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),  // 아이콘↔타이틀
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),                // 위
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),     // 오른쪽

            // 값 (예: "95권")
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),            // 타이틀과 왼쪽 정렬
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),   // 타이틀↔값
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),         // 아래
        ])
    }

    /// 넓은 카드: icon + title + spacer + value
    func setupWideLayout() {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.spacing = 0
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(spacer)
        contentStack.addArrangedSubview(valueLabel)

        contentStack.setCustomSpacing(8, after: iconImageView)  // 아이콘↔타이틀만 8

        addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
}
