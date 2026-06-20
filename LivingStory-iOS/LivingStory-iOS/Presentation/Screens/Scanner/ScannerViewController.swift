//
//  ScannerViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

// MARK: - Scanner State

enum ScannerState {
    case scanning
    case recognizing
    case success
    case failed
}

// MARK: - ScannerViewController

final class ScannerViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    /// 독서 플로우 중 "다른 책 스캔"으로 열린 경우 true
    var isRestarting = false

    private var state: ScannerState = .scanning {
        didSet { transition(to: state) }
    }

    private var detectedISBN: String?
    private var fetchedBook: BookProfileModel?
    private var lookupTask: Task<Void, Never>?

    let scanningDetent = UISheetPresentationController.Detent.custom(identifier: .init("scanning")) { context in
        context.maximumDetentValue * 0.75
    }
    private let compactDetent = UISheetPresentationController.Detent.custom(identifier: .init("compact")) { context in
        context.maximumDetentValue * 0.45
    }
    private let failedDetent = UISheetPresentationController.Detent.custom(identifier: .init("failed")) { context in
        context.maximumDetentValue * 0.55
    }

    private lazy var animator = ScannerAnimator(resultView: resultContentView)

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = DynamicLabel()
        label.text = StringLiterals.Scanner.title
        label.font = .body2SemiBold
        label.textColor = UIColor(named: "gray10")
        label.textAlignment = .center
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        button.setImage(UIImage(.close)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "gray50")
        button.backgroundColor = UIColor(named: "gray90")
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        return button
    }()

    private let scanningContentView = ScannerScanningContentView()
    private let resultContentView = ScannerResultContentView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupActions()

        scanningContentView.cameraDelegate = self
        scanningContentView.checkPermissionAndSetup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanningContentView.startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanningContentView.stopScanning()
        animator.stopDotAnimation()
    }
}

// MARK: - CameraPreviewDelegate

extension ScannerViewController: CameraPreviewDelegate {
    func cameraPreview(_ view: CameraPreviewView, didDetectBarcode isbn: String) {
        guard state == .scanning else { return }
        detectedISBN = isbn
        state = .recognizing
    }

    func cameraPreviewPermissionDenied(_ view: CameraPreviewView) {
        showPermissionAlert()
    }
}

// MARK: - Setup

private extension ScannerViewController {

    func setupStyle() {
        view.backgroundColor = .white
    }

    func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(scanningContentView)
        view.addSubview(resultContentView)
    }

    func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        scanningContentView.translatesAutoresizingMaskIntoConstraints = false
        resultContentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            scanningContentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scanningContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanningContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanningContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resultContentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            resultContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        resultContentView.retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }
}

// MARK: - State Transition

private extension ScannerViewController {

    func transition(to state: ScannerState) {
        animator.stopDotAnimation()
        updateDetent(for: state)

        UIView.animate(withDuration: 0.3) {
            self.updateVisibility(for: state)
        }

        switch state {
        case .scanning:
            scanningContentView.startScanning()

        case .recognizing:
            scanningContentView.stopScanning()
            resultContentView.resetState()
            animator.showRecognizing()

            lookupTask = Task { [weak self] in
                guard let self, let isbn = self.detectedISBN else { return }

                let startTime = Date()

                do {
                    let book = try await ISBNLookupService.shared.lookupBook(isbn: isbn)
                    guard !Task.isCancelled else { return }
                    self.fetchedBook = book

                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed < 2.0 {
                        try await Task.sleep(nanoseconds: UInt64((2.0 - elapsed) * 1_000_000_000))
                    }
                    guard !Task.isCancelled else { return }
                    self.state = .success
                } catch is CancellationError {
                    return
                } catch {
                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed < 2.0 {
                        try? await Task.sleep(nanoseconds: UInt64((2.0 - elapsed) * 1_000_000_000))
                    }
                    guard !Task.isCancelled else { return }
                    self.state = .failed
                }
            }

        case .success:
            animator.showSuccess()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self, let book = self.fetchedBook else { return }
                self.dismiss(animated: true) {
                    if self.isRestarting {
                        self.coordinator?.replaceReadingFlow(with: book)
                    } else {
                        self.coordinator?.showBookProfile(book: book)
                    }
                }
            }

        case .failed:
            animator.showFailed()
        }
    }

    func updateVisibility(for state: ScannerState) {
        scanningContentView.alpha = state == .scanning ? 1 : 0
        scanningContentView.isHidden = state != .scanning

        resultContentView.alpha = state == .scanning ? 0 : 1
        resultContentView.isHidden = state == .scanning

        resultContentView.updateVisibility(showRetry: state == .failed)
    }

    func updateDetent(for state: ScannerState) {
        guard let sheet = sheetPresentationController else { return }
        let targetDetent: UISheetPresentationController.Detent

        switch state {
        case .scanning:
            targetDetent = scanningDetent
        case .recognizing, .success:
            targetDetent = compactDetent
        case .failed:
            targetDetent = failedDetent
        }

        sheet.animateChanges {
            sheet.detents = [targetDetent]
            sheet.selectedDetentIdentifier = targetDetent.identifier
        }
    }
}

// MARK: - Permission Alert

private extension ScannerViewController {

    func showPermissionAlert() {
        let alert = UIAlertController(
            title: StringLiterals.Scanner.cameraPermissionTitle,
            message: StringLiterals.Scanner.cameraPermissionMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: StringLiterals.Scanner.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: StringLiterals.Scanner.goToSettings, style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - Actions

private extension ScannerViewController {

    @objc func closeTapped() {
        lookupTask?.cancel()
        scanningContentView.stopScanning()
        animator.stopDotAnimation()
        dismiss(animated: true)
    }

    @objc func retryTapped() {
        lookupTask?.cancel()
        fetchedBook = nil
        state = .scanning
    }
}
