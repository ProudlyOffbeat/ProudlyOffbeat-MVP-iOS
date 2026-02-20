//
//  ScannerResultContentView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import UIKit

final class ScannerResultContentView: UIView {

    // MARK: - UI Components (ScannerAnimator에서 접근)

    let barcodeIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
        let imageView = UIImageView(image: UIImage(.scanner)?.withConfiguration(config))
        imageView.tintColor = UIColor(named: "gray10")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadlineRegular
        label.textColor = UIColor(named: "gray30")
        label.textAlignment = .center
        return label
    }()

    let failedIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let imageView = UIImageView(image: UIImage(.error)?.withConfiguration(config))
        imageView.tintColor = .systemRed
        imageView.isHidden = true
        return imageView
    }()

    let successIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let imageView = UIImageView(image: UIImage(.checkmarkCircle)?.withConfiguration(config))
        imageView.tintColor = .systemGreen
        imageView.isHidden = true
        return imageView
    }()

    let retryButton = PrimaryButton(
        title: StringLiterals.Scanner.retry,
        font: .bodyEmphasized,
        backgroundColor: .black,
        cornerRadius: 28
    )

    // MARK: - Private

    private let centerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 28
        return stack
    }()

    private let statusContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        setupHierarchy()
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func resetState() {
        failedIcon.isHidden = true
        successIcon.isHidden = true
        statusLabel.isHidden = false
        retryButton.isHidden = true
        retryButton.alpha = 0

        let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
        barcodeIconView.image = UIImage(.scanner)?.withConfiguration(config)
        barcodeIconView.tintColor = UIColor(named: "gray0")
        barcodeIconView.transform = .identity
        barcodeIconView.alpha = 1
    }

    func updateVisibility(showRetry: Bool) {
        retryButton.alpha = showRetry ? 1 : 0
        retryButton.isHidden = !showRetry
    }

    func configureForPreview(state: ScannerState) {
        isHidden = false

        switch state {
        case .scanning:
            break

        case .recognizing:
            resetState()
            statusLabel.text = StringLiterals.Scanner.recognizing + "..."
            statusLabel.textColor = UIColor(named: "gray50")

        case .success:
            let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
            barcodeIconView.image = UIImage(.checkmarkCircle)?.withConfiguration(config)
            barcodeIconView.tintColor = .systemGreen
            statusLabel.text = StringLiterals.Scanner.success
            statusLabel.textColor = .systemGreen
            successIcon.isHidden = false
            failedIcon.isHidden = true
            retryButton.isHidden = true

        case .failed:
            let config = UIImage.SymbolConfiguration(pointSize: 106, weight: .regular)
            barcodeIconView.image = UIImage(.scanner)?.withConfiguration(config)
            barcodeIconView.tintColor = UIColor(named: "gray0")
            statusLabel.text = StringLiterals.Scanner.failed
            statusLabel.textColor = .systemRed
            failedIcon.isHidden = false
            successIcon.isHidden = true
            retryButton.isHidden = false
            retryButton.alpha = 1
        }
    }
}

// MARK: - Setup

private extension ScannerResultContentView {

    func setupHierarchy() {
        addSubview(centerStack)
        addSubview(retryButton)

        centerStack.addArrangedSubview(barcodeIconView)
        centerStack.addArrangedSubview(statusContainerView)

        statusContainerView.addArrangedSubview(failedIcon)
        statusContainerView.addArrangedSubview(successIcon)
        statusContainerView.addArrangedSubview(statusLabel)
    }

    func setupLayout() {
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),

            retryButton.topAnchor.constraint(equalTo: centerStack.bottomAnchor, constant: 43),
            retryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            retryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            retryButton.heightAnchor.constraint(equalToConstant: 56),
        ])
    }
}

// MARK: - Preview

#Preview("인식중") {
    let vc = UIViewController()
    vc.view.backgroundColor = .white
    let resultView = ScannerResultContentView()
    resultView.configureForPreview(state: .recognizing)
    vc.view.addSubview(resultView)
    resultView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        resultView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 50),
        resultView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
        resultView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        resultView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
    ])
    return vc
}

#Preview("인식 완료") {
    let vc = UIViewController()
    vc.view.backgroundColor = .white
    let resultView = ScannerResultContentView()
    resultView.configureForPreview(state: .success)
    vc.view.addSubview(resultView)
    resultView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        resultView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 50),
        resultView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
        resultView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        resultView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
    ])
    return vc
}

#Preview("인식 실패") {
    let vc = UIViewController()
    vc.view.backgroundColor = .white
    let resultView = ScannerResultContentView()
    resultView.configureForPreview(state: .failed)
    vc.view.addSubview(resultView)
    resultView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        resultView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 50),
        resultView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
        resultView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
        resultView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
    ])
    return vc
}
