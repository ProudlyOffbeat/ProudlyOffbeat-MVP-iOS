//
//  HomeDeviceCardView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/11/26.
//

import UIKit

final class HomeDeviceCardView: UIView {

    private var homeDeviceType: HomeDeviceType
    private var homeDeviceState: Bool = false
    private var deviceIndex: Int = 0        // 룸 내 순번 (홀/짝으로 ON 색 결정)

    // 그라데이션 보더 (켜졌을 때만 표시)
    private let borderGradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    private let homeIconDeviceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22)
        return imageView
    }()

    private let deviceNameLabel: UILabel = {
        let nameLabel = DynamicLabel()
        nameLabel.font = .calloutMedium          // Callout Medium
        return nameLabel
    }()

    private let deviceStatusLabel: UILabel = {
        let stateLabel = DynamicLabel()
        stateLabel.font = .labelMedium           // Label Medium
        return stateLabel
    }()

    private let labelStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    //MARK: - 초기화
    init(deviceType: HomeDeviceType) {
        self.homeDeviceType = deviceType
        super.init(frame: .zero)

        setupStyle()
        setupHierarchy()
        setupLayout()
        setupAccessibility()
        updateAppearance()
    }

    //MARK: - Swift 6 이후부터는 UIView class가 스토리보드 명시적으로 사용하기 때문에 스토리보드 사용안한다는 명시적 확인을 해줘야함.
    // -> Storyboard 디코딩용 init인데, 코드 기반 UI라 @available(*, unavailable)로 사용을 막음.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 보더 그라데이션 ring 갱신
        borderGradientLayer.frame = bounds
        let lineWidth: CGFloat = 1.5
        let path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2),
            cornerRadius: 20
        )
        borderMaskLayer.path = path.cgPath
        borderMaskLayer.lineWidth = lineWidth
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor   // 불투명 → 보더만 그라데이션 노출
    }
}


//MARK: - Public Methods

extension HomeDeviceCardView {
    func configure(with device: DeviceModel, index: Int) {
        self.homeDeviceType = device.deviceType
        self.homeDeviceState = device.isOn
        self.deviceIndex = index
        deviceNameLabel.text = device.name
        deviceStatusLabel.text = device.status
        updateAppearance()
        updateAccessibilityLabel()
    }
}

private extension HomeDeviceCardView {

    func setupStyle() {
        layer.cornerRadius = 20
        clipsToBounds = true
        borderGradientLayer.mask = borderMaskLayer
        layer.addSublayer(borderGradientLayer)
    }

    func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityHint = "이중 탭하여 전원을 전환합니다"
    }

    func updateAccessibilityLabel() {
        let deviceTypeName = homeDeviceType == .light ? "조명" : "스피커"
        let stateName = homeDeviceState ? "켜짐" : "꺼짐"
        accessibilityLabel = "\(deviceNameLabel.text ?? "") \(deviceTypeName), \(stateName)"
    }

    func setupHierarchy() {
        addSubview(homeIconDeviceImageView)
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(deviceNameLabel)
        labelStackView.addArrangedSubview(deviceStatusLabel)
    }

    func setupLayout() {
        homeIconDeviceImageView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 아이콘 (상·좌측 14, 박스 없이 심볼만)
            homeIconDeviceImageView.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            homeIconDeviceImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            // 라벨 스택뷰
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    func updateAppearance() {
        homeIconDeviceImageView.image = homeDeviceType.homeIcon

        if homeDeviceState {
            activateStyle()
        } else {
            inactivateStyle()
        }
    }

    func activateStyle() {
        let isOddPosition = deviceIndex % 2 == 0   // 룸 내 1·3·5번째 → 노랑
        if isOddPosition {
            backgroundColor = UIColor(named: "yellow900")
            applyBorderGradient(AppGradient.g10)
            homeIconDeviceImageView.tintColor = UIColor(named: "yellow80")
            deviceStatusLabel.textColor = UIColor(named: "yellow60")
        } else {
            backgroundColor = UIColor(named: "blue800")
            applyBorderGradient(AppGradient.g20)
            homeIconDeviceImageView.tintColor = UIColor(named: "blue0")
            deviceStatusLabel.textColor = UIColor(named: "blue0")
        }
        deviceNameLabel.textColor = .white          // Labels Primary
    }

    func inactivateStyle() {
        backgroundColor = UIColor(hex: 0x3A3A3C)
        borderGradientLayer.isHidden = true
        homeIconDeviceImageView.tintColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.3)
        deviceNameLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)
        deviceStatusLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.3)
    }

    func applyBorderGradient(_ token: GradientToken) {
        let source = token.makeLayer()
        borderGradientLayer.colors = source.colors
        borderGradientLayer.locations = source.locations
        borderGradientLayer.startPoint = source.startPoint
        borderGradientLayer.endPoint = source.endPoint
        borderGradientLayer.isHidden = false
    }
}

extension HomeDeviceType {
    var homeIcon: UIImage? {
        switch self {
        case .light: return UIImage(.lightbulb)
        case .speaker: return UIImage(.speaker)
        }
    }
}
