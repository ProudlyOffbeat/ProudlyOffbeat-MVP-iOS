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
    /// 직전 표시 상태 — OFF→ON 전환을 감지해 켜짐 애니메이션을 재생한다.
    /// nil이면 (신규/재사용 셀) 애니메이션 없이 최종 상태만 반영.
    private var wasOn: Bool?

    // 그라데이션 보더 (켜졌을 때만 표시)
    private let borderGradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    // MARK: - 배지/글로우 상수

    private static let badgeSize: CGFloat = 44
    private static let badgeOffFill = UIColor(hex: 0x545458)   // 꺼짐: 회색 원
    private static let restGlowOpacity: Float = 0.5            // 켜짐 유지 시 은은한 잔광
    private static let restGlowRadius: CGFloat = 7

    // 아이콘을 감싸는 원형 배지 — 홈앱처럼 상태 색을 담고, 켜질 때 빛이 번진다.
    private let iconBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = HomeDeviceCardView.badgeSize / 2
        view.clipsToBounds = false          // 글로우(그림자)가 배지 밖으로 번지도록
        view.layer.shadowOffset = .zero
        return view
    }()

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

        // 배지 글로우 경로를 원형으로 고정 (성능 + 정확한 번짐)
        iconBadge.layer.shadowPath = UIBezierPath(ovalIn: iconBadge.bounds).cgPath
    }
}


//MARK: - Public Methods

extension HomeDeviceCardView {
    func configure(with device: DeviceModel, index: Int) {
        self.homeDeviceType = device.deviceType
        self.homeDeviceState = device.displayIsOn   // 옵티미스틱 우선 — 탭 즉시 목표 상태로 그림
        deviceNameLabel.text = device.name
        deviceStatusLabel.text = device.status
        updateAppearance()
        updateAccessibilityLabel(isPending: device.isPending)
    }

    /// 셀 재사용 직전 호출 — 전환 감지 상태와 진행 중 애니메이션을 초기화해
    /// 스크롤 중 엉뚱한 셀에서 켜짐 애니메이션이 튀는 것을 막는다.
    func resetForReuse() {
        wasOn = nil
        iconBadge.layer.removeAllAnimations()
        iconBadge.transform = .identity
        homeIconDeviceImageView.transform = .identity
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

    func updateAccessibilityLabel(isPending: Bool) {
        let deviceTypeName = homeDeviceType == .light ? "조명" : "스피커"
        let stateName = homeDeviceState ? "켜짐" : "꺼짐"
        let pendingSuffix = isPending ? ", 적용 중" : ""
        accessibilityLabel = "\(deviceNameLabel.text ?? "") \(deviceTypeName), \(stateName)\(pendingSuffix)"
    }

    func setupHierarchy() {
        addSubview(iconBadge)
        iconBadge.addSubview(homeIconDeviceImageView)
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(deviceNameLabel)
        labelStackView.addArrangedSubview(deviceStatusLabel)
    }

    func setupLayout() {
        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        homeIconDeviceImageView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 원형 배지 (상·좌측)
            iconBadge.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBadge.widthAnchor.constraint(equalToConstant: Self.badgeSize),
            iconBadge.heightAnchor.constraint(equalToConstant: Self.badgeSize),

            // 아이콘은 배지 중앙
            homeIconDeviceImageView.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            homeIconDeviceImageView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),

            // 라벨 스택뷰
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Appearance

    func updateAppearance() {
        let theme = homeDeviceType.theme
        homeIconDeviceImageView.image = homeDeviceType.homeIcon

        let isOn = homeDeviceState
        // 이미 화면에 있고(=window) 상태가 실제로 바뀐 경우에만 켜짐/꺼짐 전환 애니메이션.
        let animated = (wasOn != nil && wasOn != isOn && window != nil)

        // 카드 배경 · 보더 · 라벨
        if isOn {
            backgroundColor = theme.cardOn
            applyBorderGradient(theme.border)
            deviceNameLabel.textColor = .white
            deviceStatusLabel.textColor = theme.statusOn
        } else {
            backgroundColor = UIColor(hex: 0x3A3A3C)
            borderGradientLayer.isHidden = true
            deviceNameLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)
            deviceStatusLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.35)
        }

        renderBadge(isOn: isOn, theme: theme, animated: animated)
        wasOn = isOn
    }

    /// 배지(원 + 아이콘)를 상태에 맞게 렌더. 켜짐 전환이면 "확 켜지는" 글로우 애니메이션.
    func renderBadge(isOn: Bool, theme: DeviceCardTheme, animated: Bool) {
        if isOn {
            iconBadge.backgroundColor = theme.badgeOnFill
            homeIconDeviceImageView.tintColor = .white     // 켜짐: 흰 아이콘
            iconBadge.layer.shadowColor = theme.badgeOnFill.cgColor

            if animated {
                playTurnOn()
            } else {
                iconBadge.transform = .identity
                homeIconDeviceImageView.transform = .identity
                iconBadge.layer.shadowOpacity = Self.restGlowOpacity   // 잔광 유지
                iconBadge.layer.shadowRadius = Self.restGlowRadius
            }
        } else {
            // 꺼짐: 회색 원 + 컴포넌트 고유색 아이콘(죽은 회색 아님)
            let applyOff = {
                self.iconBadge.backgroundColor = Self.badgeOffFill
                self.homeIconDeviceImageView.tintColor = theme.accent
            }
            if animated {
                UIView.transition(with: iconBadge, duration: 0.22, options: .transitionCrossDissolve, animations: applyOff)
            } else {
                applyOff()
            }
            iconBadge.transform = .identity
            homeIconDeviceImageView.transform = .identity
            iconBadge.layer.shadowOpacity = 0
        }
    }

    /// 전구가 확 켜지는 표현: ① 스프링 스케일 팝 ② 빛무리(글로우)가 확 번졌다가 잔광으로 가라앉음.
    func playTurnOn() {
        // ① 스케일 팝 — 배지는 살짝, 아이콘은 크게 튕겨 "탁" 켜지는 느낌
        iconBadge.transform = CGAffineTransform(scaleX: 0.86, y: 0.86)
        homeIconDeviceImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.7,
            options: [.allowUserInteraction]
        ) {
            self.iconBadge.transform = .identity
            self.homeIconDeviceImageView.transform = .identity
        }

        // ② 글로우 블룸 — 0 → 강하게 → 은은한 잔광
        let glowOpacity = CAKeyframeAnimation(keyPath: "shadowOpacity")
        glowOpacity.values = [0.0, 1.0, Self.restGlowOpacity]
        glowOpacity.keyTimes = [0.0, 0.4, 1.0]
        glowOpacity.duration = 0.6
        glowOpacity.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let glowRadius = CAKeyframeAnimation(keyPath: "shadowRadius")
        glowRadius.values = [2.0, 16.0, Self.restGlowRadius]
        glowRadius.keyTimes = [0.0, 0.4, 1.0]
        glowRadius.duration = 0.6
        glowRadius.timingFunction = CAMediaTimingFunction(name: .easeOut)

        // 애니메이션 종료 후 머무를 최종값 먼저 세팅 (튐 방지)
        iconBadge.layer.shadowOpacity = Self.restGlowOpacity
        iconBadge.layer.shadowRadius = Self.restGlowRadius
        iconBadge.layer.add(glowOpacity, forKey: "turnOnGlowOpacity")
        iconBadge.layer.add(glowRadius, forKey: "turnOnGlowRadius")
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

// MARK: - Device Theme (컴포넌트 타입별 색상)

/// 기기 타입마다 고유한 색 테마. 위치(홀/짝)가 아니라 "무슨 기기인가"로 색이 정해진다.
fileprivate struct DeviceCardTheme {
    let cardOn: UIColor          // 켜짐 카드 배경
    let border: GradientToken    // 켜짐 보더 그라데이션
    let badgeOnFill: UIColor     // 켜짐 배지 원(+글로우 색)
    let accent: UIColor          // 꺼짐 아이콘 색 (고유색 유지)
    let statusOn: UIColor        // 켜짐 상태 텍스트 색
}

fileprivate extension HomeDeviceType {
    var theme: DeviceCardTheme {
        switch self {
        case .light:
            return DeviceCardTheme(
                cardOn: UIColor(named: "yellow900") ?? UIColor(hex: 0x524922),
                border: AppGradient.g10,
                badgeOnFill: UIColor(named: "yellow0") ?? UIColor(hex: 0xFBC928),
                accent: UIColor(named: "yellow80") ?? UIColor(hex: 0xFFE451),
                statusOn: UIColor(named: "yellow60") ?? UIColor(hex: 0xFCDF42)
            )
        case .speaker:
            return DeviceCardTheme(
                cardOn: UIColor(named: "blue800") ?? UIColor(hex: 0x314760),
                border: AppGradient.g20,
                badgeOnFill: UIColor(named: "blue60") ?? UIColor(hex: 0x6BB2FB),
                accent: UIColor(named: "blue0") ?? UIColor(hex: 0x87C2FF),
                statusOn: UIColor(named: "blue0") ?? UIColor(hex: 0x87C2FF)
            )
        }
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
