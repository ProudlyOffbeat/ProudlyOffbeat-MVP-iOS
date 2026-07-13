//
//  WormPageControl.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class WormPageControl: UIView {

    // MARK: - Properties

    var numberOfPages: Int = 0 {
        didSet { invalidateIntrinsicContentSize(); setNeedsDisplay() }
    }

    /// 스크롤 진행률 (0.0 = 첫 페이지, 1.0 = 두 번째 페이지, ...)
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    var dotSize: CGFloat = 8
    var dotSpacing: CGFloat = 12
    var activeColor: UIColor = .white                 // 선택된 점
    var inactiveColor: UIColor = UIColor(hex: 0x404040)  // 나머지 점

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        guard numberOfPages > 0 else { return .zero }
        let width = CGFloat(numberOfPages) * dotSize + CGFloat(numberOfPages - 1) * dotSpacing
        return CGSize(width: width, height: dotSize)
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard numberOfPages > 0, let context = UIGraphicsGetCurrentContext() else { return }

        let totalWidth = CGFloat(numberOfPages) * dotSize + CGFloat(numberOfPages - 1) * dotSpacing
        let startX = (bounds.width - totalWidth) / 2
        let centerY = bounds.height / 2

        // 비활성 도트 그리기
        inactiveColor.setFill()
        for i in 0..<numberOfPages {
            let centerX = startX + dotSize / 2 + CGFloat(i) * (dotSize + dotSpacing)
            let dotRect = CGRect(
                x: centerX - dotSize / 2,
                y: centerY - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            context.fillEllipse(in: dotRect)
        }

        // 웜(활성 인디케이터) 그리기
        let clampedProgress = max(0, min(progress, CGFloat(numberOfPages - 1)))
        let currentIndex = Int(clampedProgress)
        let fraction = clampedProgress - CGFloat(currentIndex)

        let currentCenterX = startX + dotSize / 2 + CGFloat(currentIndex) * (dotSize + dotSpacing)

        if fraction < 0.01 || fraction > 0.99 || currentIndex >= numberOfPages - 1 {
            // 정확히 도트 위치에 있을 때 → 원형
            let finalIndex: Int
            if fraction > 0.99, currentIndex < numberOfPages - 1 {
                finalIndex = currentIndex + 1
            } else if currentIndex >= numberOfPages - 1 {
                finalIndex = numberOfPages - 1
            } else {
                finalIndex = currentIndex
            }
            let cx = startX + dotSize / 2 + CGFloat(finalIndex) * (dotSize + dotSpacing)
            let dotRect = CGRect(
                x: cx - dotSize / 2,
                y: centerY - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            activeColor.setFill()
            let path = UIBezierPath(roundedRect: dotRect, cornerRadius: dotSize / 2)
            path.fill()
        } else {
            // 웜 스트레칭 효과
            let nextCenterX = startX + dotSize / 2 + CGFloat(currentIndex + 1) * (dotSize + dotSpacing)

            // 앞쪽(leading)은 먼저 움직이고, 뒤쪽(trailing)은 뒤따라감
            let leadingProgress = min(fraction * 2, 1.0)
            let trailingProgress = max((fraction - 0.5) * 2, 0.0)

            let leadingX = currentCenterX + (nextCenterX - currentCenterX) * leadingProgress
            let trailingX = currentCenterX + (nextCenterX - currentCenterX) * trailingProgress

            let wormRect = CGRect(
                x: trailingX - dotSize / 2,
                y: centerY - dotSize / 2,
                width: (leadingX - trailingX) + dotSize,
                height: dotSize
            )

            activeColor.setFill()
            let path = UIBezierPath(roundedRect: wormRect, cornerRadius: dotSize / 2)
            path.fill()
        }
    }
}
