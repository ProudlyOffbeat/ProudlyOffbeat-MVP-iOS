//
//  ScannerAnimator.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class ScannerAnimator {

    // MARK: - Properties

    private weak var resultView: ScannerResultContentView?

    private var dotTimer: Timer?
    private var dotCount = 0

    // MARK: - Init

    init(resultView: ScannerResultContentView) {
        self.resultView = resultView
    }

    // MARK: - Public Methods

    func showRecognizing() {
        guard let resultView else { return }

        let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
        resultView.barcodeIconView.image = UIImage(.scanner)?.withConfiguration(config)
        resultView.barcodeIconView.tintColor = .white   // Labels Primary
        resultView.barcodeIconView.addSymbolEffect(.pulse.byLayer)

        resultView.statusLabel.isHidden = false
        resultView.statusLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)  // Labels Secondary
        resultView.failedIcon.isHidden = true
        resultView.successIcon.isHidden = true

        startDotAnimation()
    }

    func showSuccess() {
        guard let resultView else { return }

        resultView.barcodeIconView.removeAllSymbolEffects()

        let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
        resultView.barcodeIconView.image = UIImage(.checkmarkCircle)?.withConfiguration(config)
        resultView.barcodeIconView.tintColor = .systemGreen
        resultView.barcodeIconView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        resultView.barcodeIconView.alpha = 0

        resultView.barcodeIconView.superview?.layoutIfNeeded()

        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut
        ) {
            resultView.barcodeIconView.transform = .identity
            resultView.barcodeIconView.alpha = 1
        }

        if let iconSuperview = resultView.barcodeIconView.superview {
            addRingPulse(to: iconSuperview, center: resultView.barcodeIconView.center)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            resultView.barcodeIconView.addSymbolEffect(.bounce)
        }

        resultView.statusLabel.isHidden = false
        resultView.statusLabel.text = StringLiterals.Scanner.success
        resultView.statusLabel.textColor = .systemGreen
        resultView.statusLabel.alpha = 0
        resultView.failedIcon.isHidden = true
        resultView.successIcon.isHidden = false
        resultView.successIcon.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0.4) {
            resultView.statusLabel.alpha = 1
            resultView.successIcon.alpha = 1
        } completion: { _ in
            resultView.successIcon.addSymbolEffect(.bounce)
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func showFailed() {
        guard let resultView else { return }

        resultView.barcodeIconView.removeAllSymbolEffects()

        let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
        resultView.barcodeIconView.image = UIImage(.scanner)?.withConfiguration(config)
        resultView.barcodeIconView.tintColor = .white   // Labels Primary

        resultView.statusLabel.isHidden = false
        resultView.statusLabel.text = StringLiterals.Scanner.failed
        resultView.statusLabel.textColor = UIColor(hex: 0xEBEBF5).withAlphaComponent(0.7)  // Labels Secondary
        resultView.failedIcon.isHidden = false
        resultView.successIcon.isHidden = true

        resultView.failedIcon.alpha = 0
        resultView.statusLabel.alpha = 0
        resultView.retryButton.alpha = 0

        UIView.animate(withDuration: 0.2, delay: 0.1) {
            resultView.failedIcon.alpha = 1
            resultView.statusLabel.alpha = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            resultView.retryButton.alpha = 1
        }
    }

    func stopDotAnimation() {
        dotTimer?.invalidate()
        dotTimer = nil
    }
}

// MARK: - Private Methods

private extension ScannerAnimator {

    func startDotAnimation() {
        dotCount = 0
        updateDotText()
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.dotCount = (self.dotCount + 1) % 4
            self.updateDotText()
        }
    }

    func updateDotText() {
        let dots = String(repeating: ".", count: dotCount)
        resultView?.statusLabel.text = StringLiterals.Scanner.recognizing + dots
    }

    func addRingPulse(to parentView: UIView, center: CGPoint) {
        let ringLayer = CAShapeLayer()
        let initialRadius: CGFloat = 30
        let finalRadius: CGFloat = 80
        let initialPath = UIBezierPath(
            arcCenter: center, radius: initialRadius,
            startAngle: 0, endAngle: .pi * 2, clockwise: true
        )
        let finalPath = UIBezierPath(
            arcCenter: center, radius: finalRadius,
            startAngle: 0, endAngle: .pi * 2, clockwise: true
        )

        ringLayer.path = initialPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = UIColor.systemGreen.withAlphaComponent(0.6).cgColor
        ringLayer.lineWidth = 3
        parentView.layer.addSublayer(ringLayer)

        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = initialPath.cgPath
        pathAnimation.toValue = finalPath.cgPath

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.0

        let group = CAAnimationGroup()
        group.animations = [pathAnimation, opacityAnimation]
        group.duration = 0.8
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        ringLayer.add(group, forKey: "ringPulse")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            ringLayer.removeFromSuperlayer()
        }
    }
}
