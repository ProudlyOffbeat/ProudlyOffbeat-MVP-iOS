//
//  CoachMarkOverlayView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  코치마크 오버레이 (온보딩 Instructions)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  말풍선(본체 + 꼬리)을 하나의 UIBezierPath로 그려서
//  경계선 없이 자연스러운 speech bubble을 구현한다.
//  화살표 끝은 AMPopTip 방식의 arc로 둥글게 처리한다.
//  탭 중앙은 균등 분할로 안정적으로 계산한다.
//
//  디자인 스펙:
//  - 말풍선: Atomic/Gray/20 = rgba(0,0,0,0.75)
//  - 배경 오버레이: Miscellaneous/Alert Overlay = rgba(41,41,58,0.23)
//  - 내부 패딩: 16 상하좌우
//  - 타이틀: gray100, subheadline/emphasized
//  - 타이틀↔설명: 4
//  - 설명: gray100, subheadline/regular
//  - 설명↔스텝: 16
//  - 스텝: footnote/regular, gray90
//  - 버튼: footnote/emphasized, gray100 border 1, padding 6/12, radius 14
//
//  참고: https://github.com/andreamazz/AMPopTip (arrowRadius 기법)
//

import UIKit

// MARK: - CoachMarkOverlayView

final class CoachMarkOverlayView: UIView {

    // MARK: - Types

    private struct Step {
        let title: String
        let message: String
        let tabIndex: Int
    }

    // MARK: - Properties

    var onComplete: (() -> Void)?
    var onTabSwitch: ((Int) -> Void)?

    private var currentStep = 0
    private weak var tabBar: UITabBar?
    private var isFirstLayout = true

    private let steps: [Step] = [
        Step(title: StringLiterals.TabBar.book,
             message: StringLiterals.Onboarding.coachMark1,
             tabIndex: 1),
        Step(title: "환경 세팅",
             message: StringLiterals.Onboarding.coachMark2,
             tabIndex: 0),
        Step(title: StringLiterals.TabBar.my,
             message: StringLiterals.Onboarding.coachMark3,
             tabIndex: 2)
    ]

    // MARK: - Constants

    private let padding: CGFloat = 16          // 좌우·하단
    private let topPadding: CGFloat = 14       // 상단
    private let stepTitleGap: CGFloat = 12     // 1/3 ↔ 제목
    private let titleMsgGap: CGFloat = 10       // 제목 ↔ 설명
    private let msgBtnGap: CGFloat = 16        // 설명 ↔ 버튼
    private let arrowTailHeight: CGFloat = 10
    private let bubbleMargin: CGFloat = 20
    private let maxContentWidth: CGFloat = 300   // 환경 세팅 설명이 한 줄로 들어가게

    // MARK: - UI Components

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(
            red: 41/255, green: 41/255, blue: 58/255, alpha: 0.5
        )
        return view
    }()

    private let bubbleView = SpeechBubbleView()

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .body2Bold
        label.textColor = UIColor(named: "yellow60")
        return label
    }()

    private let messageLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .labelParagraph
        label.textColor = .label                 // Labels Primary
        label.numberOfLines = 0
        return label
    }()

    private let stepLabel: UILabel = {
        let label = DynamicLabel()
        label.font = .footnoteRegular
        label.textColor = .secondaryLabel         // Labels Secondary
        return label
    }()

    private let actionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 10
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    /// 마지막(시작하기) 버튼용 Gradation 40
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = AppGradient.g40.makeLayer()
        layer.cornerRadius = 10
        layer.isHidden = true
        return layer
    }()

    /// 재사용 햅틱 (prepare로 지연/리소스 최소화)
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Init

    init(tabBar: UITabBar) {
        self.tabBar = tabBar
        super.init(frame: .zero)
        setupHierarchy()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dimView.frame = bounds
        if isFirstLayout {
            isFirstLayout = false
            showStep(0)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = actionButton.convert(point, from: self)
        if actionButton.bounds.contains(buttonPoint) {
            return actionButton
        }
        return self
    }
}

// MARK: - SpeechBubbleView (본체 + 꼬리 = 하나의 Path)

private final class SpeechBubbleView: UIView {

    var arrowPointX: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    private let bubbleColor = UIColor.tertiarySystemBackground
    private let cornerRadius: CGFloat = 16
    private let arrowWidth: CGFloat = 28
    private let arrowHeight: CGFloat = 10
    private let arrowTipRadius: CGFloat = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var bodyRect: CGRect {
        CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - arrowHeight)
    }

    override func draw(_ rect: CGRect) {
        guard bounds.width > 0, bounds.height > arrowHeight else { return }

        let body = bodyRect
        let r = cornerRadius

        let clampedX = min(max(arrowPointX, r + arrowWidth / 2), body.width - r - arrowWidth / 2)
        let halfW = arrowWidth / 2

        // 화살표 3개 점
        let arrowStart = CGPoint(x: clampedX + halfW, y: body.maxY)
        let arrowVertex = CGPoint(x: clampedX, y: body.maxY + arrowHeight)
        let arrowEnd = CGPoint(x: clampedX - halfW, y: body.maxY)

        let path = UIBezierPath()

        // ── 본체 둥근 사각형 ──

        // 좌상단 시작
        path.move(to: CGPoint(x: r, y: 0))

        // 상단 →
        path.addLine(to: CGPoint(x: body.maxX - r, y: 0))
        path.addArc(
            withCenter: CGPoint(x: body.maxX - r, y: r),
            radius: r, startAngle: -.pi / 2, endAngle: 0, clockwise: true
        )

        // 우측 ↓
        path.addLine(to: CGPoint(x: body.maxX, y: body.maxY - r))
        path.addArc(
            withCenter: CGPoint(x: body.maxX - r, y: body.maxY - r),
            radius: r, startAngle: 0, endAngle: .pi / 2, clockwise: true
        )

        // ── 하단 + 화살표 꼬리 ──

        // 하단 ← (꼬리 시작점까지)
        path.addLine(to: arrowStart)

        // 꼬리: 시작 → 꼭지점 (arc로 둥글게) → 끝
        if let arcInfo = Self.roundCornerArc(
            start: arrowStart, vertex: arrowVertex, end: arrowEnd, radius: arrowTipRadius
        ) {
            path.addLine(to: arcInfo.tangentStart)
            path.addArc(
                withCenter: arcInfo.center,
                radius: arrowTipRadius,
                startAngle: arcInfo.startAngle,
                endAngle: arcInfo.endAngle,
                clockwise: true
            )
            path.addLine(to: arrowEnd)
        } else {
            // fallback: 직선
            path.addLine(to: arrowVertex)
            path.addLine(to: arrowEnd)
        }

        // 하단 ← (나머지)
        path.addLine(to: CGPoint(x: r, y: body.maxY))
        path.addArc(
            withCenter: CGPoint(x: r, y: body.maxY - r),
            radius: r, startAngle: .pi / 2, endAngle: .pi, clockwise: true
        )

        // 좌측 ↑
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addArc(
            withCenter: CGPoint(x: r, y: r),
            radius: r, startAngle: .pi, endAngle: -.pi / 2, clockwise: true
        )

        path.close()
        bubbleColor.setFill()
        path.fill()
    }

    // MARK: - 둥근 화살표 끝 계산 (AMPopTip 기법)

    private struct ArcInfo {
        let center: CGPoint
        let startAngle: CGFloat
        let endAngle: CGFloat
        let tangentStart: CGPoint
        let tangentEnd: CGPoint
    }

    private static func roundCornerArc(
        start: CGPoint, vertex: CGPoint, end: CGPoint, radius: CGFloat
    ) -> ArcInfo? {
        // 두 변의 방향 벡터
        let angle1 = atan2(start.y - vertex.y, start.x - vertex.x)
        let angle2 = atan2(end.y - vertex.y, end.x - vertex.x)

        // 이등분선으로부터 원 중심 계산
        let bisector = (angle1 + angle2) / 2
        let halfAngle = (angle1 - angle2) / 2
        let sinHalf = sin(halfAngle)

        guard abs(sinHalf) > 0.001 else { return nil }

        let dist = radius / abs(sinHalf)

        let center = CGPoint(
            x: vertex.x + dist * cos(bisector),
            y: vertex.y + dist * sin(bisector)
        )

        // 접선 시작/끝점
        let tangentDist = radius / abs(tan(halfAngle))
        let tangentStart = CGPoint(
            x: vertex.x + tangentDist * cos(angle1),
            y: vertex.y + tangentDist * sin(angle1)
        )
        let tangentEnd = CGPoint(
            x: vertex.x + tangentDist * cos(angle2),
            y: vertex.y + tangentDist * sin(angle2)
        )

        // arc 각도
        let startAngle = atan2(tangentStart.y - center.y, tangentStart.x - center.x)
        let endAngle = atan2(tangentEnd.y - center.y, tangentEnd.x - center.x)

        return ArcInfo(
            center: center,
            startAngle: startAngle,
            endAngle: endAngle,
            tangentStart: tangentStart,
            tangentEnd: tangentEnd
        )
    }
}

// MARK: - Setup

private extension CoachMarkOverlayView {

    func setupHierarchy() {
        addSubview(dimView)
        addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(stepLabel)
        bubbleView.addSubview(actionButton)
        actionButton.layer.insertSublayer(gradientLayer, at: 0)   // 마지막 버튼 그라데이션(평소 hidden)
    }

    func setupActions() {
        haptic.prepare()
        actionButton.addAction(UIAction { [weak self] _ in
            self?.haptic.impactOccurred()
            self?.haptic.prepare()        // 다음 탭 대비 재준비
            self?.nextStep()
        }, for: .touchUpInside)
    }
}

// MARK: - Tab Center (균등 분할)

private extension CoachMarkOverlayView {

    func tabItemCenterX(for index: Int) -> CGFloat {
        guard let tabBar else { return bounds.midX }

        let tabCount = CGFloat(tabBar.items?.count ?? 3)
        let tabWidth = tabBar.bounds.width / tabCount
        let localX = tabWidth * (CGFloat(index) + 0.5)
        return tabBar.convert(CGPoint(x: localX, y: 0), to: self).x
    }
}

// MARK: - Step Navigation

private extension CoachMarkOverlayView {

    func showStep(_ step: Int) {
        guard step < steps.count, let tabBar else { return }

        currentStep = step
        let data = steps[step]

        onTabSwitch?(data.tabIndex)

        // 탭바 레이아웃 확정
        tabBar.layoutIfNeeded()

        // 콘텐츠 업데이트
        titleLabel.text = data.title
        messageLabel.text = data.message
        stepLabel.text = "\(step + 1)/\(steps.count)"

        let isLastStep = step == steps.count - 1
        let buttonTitle = isLastStep ? StringLiterals.Onboarding.start : StringLiterals.Onboarding.next
        updateButtonTitle(buttonTitle, isLastStep: isLastStep)

        // 탭 정중앙 X
        let centerX = tabItemCenterX(for: data.tabIndex)

        // 탭바 상단 Y (self 좌표계)
        let tabBarTopY = tabBar.convert(CGPoint.zero, to: self).y

        // ── 콘텐츠 사이즈 계산 ──

        let titleSize = titleLabel.sizeThatFits(
            CGSize(width: maxContentWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        let msgSize = messageLabel.sizeThatFits(
            CGSize(width: maxContentWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        let stepSize = stepLabel.sizeThatFits(
            CGSize(width: 50, height: CGFloat.greatestFiniteMagnitude)
        )
        let contentWidth = max(titleSize.width, msgSize.width)
        let bubbleWidth = contentWidth + padding * 2

        // 버튼은 풀폭, 높이는 텍스트 + 상하 인셋(10)
        let btnSize = actionButton.sizeThatFits(
            CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        let btnHeight = btnSize.height

        let bodyHeight = topPadding + stepSize.height + stepTitleGap
            + titleSize.height + titleMsgGap + msgSize.height + msgBtnGap + btnHeight + padding
        let bubbleHeight = bodyHeight + arrowTailHeight

        // 말풍선 중앙 = 탭 중앙
        var bubbleX = centerX - bubbleWidth / 2
        bubbleX = max(bubbleMargin, min(bubbleX, bounds.width - bubbleWidth - bubbleMargin))
        let bubbleY = tabBarTopY - 16 - bubbleHeight

        bubbleView.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)
        let arrowOffset: CGFloat = switch data.tabIndex {
        case 0: -5    // 환경세팅
        case 2: 15    // 마이
        default: 0    // 책읽기
        }
        bubbleView.arrowPointX = bubbleWidth / 2 + arrowOffset

        // ── 내부 배치: 1/3 → 제목 → 설명 → 풀폭 버튼 ──
        var y = topPadding

        stepLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: stepSize.height)
        y += stepSize.height + stepTitleGap

        titleLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: titleSize.height)
        y += titleSize.height + titleMsgGap

        messageLabel.frame = CGRect(x: padding, y: y, width: contentWidth, height: msgSize.height)
        y += msgSize.height + msgBtnGap

        actionButton.frame = CGRect(x: padding, y: y, width: contentWidth, height: btnHeight)
        gradientLayer.frame = actionButton.bounds
    }

    func nextStep() {
        let next = currentStep + 1
        if next < steps.count {
            UIView.animate(withDuration: 0.25) {
                self.showStep(next)
            }
        } else {
            complete()
        }
    }

    func complete() {
        onTabSwitch?(1)
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.onComplete?()
        }
    }

    func updateButtonTitle(_ title: String, isLastStep: Bool) {
        var config = actionButton.configuration ?? .plain()
        // 다음 = 검정 배경 + 흰 글씨 / 시작하기 = Gradation 40 + 어두운 글씨
        let textColor: UIColor = isLastStep ? (UIColor(named: "gray0") ?? .black) : .label
        let font = UIFont(name: "Pretendard-SemiBold", size: 14)
            ?? .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: font,
                .foregroundColor: textColor
            ])
        )
        config.background.backgroundColor = isLastStep ? .clear : (UIColor(named: "gray0") ?? .black)
        actionButton.configuration = config
        gradientLayer.isHidden = !isLastStep   // 마지막(시작하기)만 그라데이션
    }
}
