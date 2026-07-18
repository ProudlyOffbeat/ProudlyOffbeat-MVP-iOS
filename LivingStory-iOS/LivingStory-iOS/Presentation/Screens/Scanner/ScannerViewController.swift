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

final class ScannerViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?
    /// 독서 플로우 중 "다른 책 스캔"으로 열린 경우 true
    var isRestarting = false

    private var state: ScannerState = .scanning {
        didSet { transition(to: state) }
    }

    private var detectedISBN: String?
    private var fetchedBook: BookProfileModel?
    /// 인식중에 미리 받아온 환경 추천 (조명·음악·대화) — 성공 시 독서 화면으로 전달
    private var preparedEnvironment: PreparedEnvironment?
    private let geminiService = GeminiService()
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
        label.font = .headlineRegular                       // Headline Regular
        label.textColor = UIColor(hex: 0xF5F5F5)
        label.textAlignment = .center
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)   // SF Pro Medium 17
        button.setImage(UIImage(.close)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(hex: 0x8A8A8A)
        button.backgroundColor = UIColor(hex: 0x787880).withAlphaComponent(0.32)   // #787880 · 32%
        button.layer.cornerRadius = 22       // 44×44 원
        button.clipsToBounds = true
        return button
    }()

    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x333333)
        view.layer.cornerRadius = 2.5
        return view
    }()

    /// X + 타이틀을 묶는 헤더 박스 (좌우 패딩 동일)
    private let headerBox = UIView()

    private let directSearchButton: UIButton = {
        var config = UIButton.Configuration.glass()   // 클리어 리퀴드 글래스
        config.title = StringLiterals.Scanner.directSearch
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 14, bottom: 13, trailing: 14)
        return UIButton(configuration: config)
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
        view.backgroundColor = UIColor(hex: 0x1C1C1E)   // 바텀시트 배경
    }

    func setupHierarchy() {
        view.addSubview(grabberView)
        view.addSubview(headerBox)
        headerBox.addSubview(titleLabel)
        headerBox.addSubview(closeButton)
        view.addSubview(scanningContentView)
        view.addSubview(resultContentView)
        view.addSubview(directSearchButton)
    }

    func setupLayout() {
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        headerBox.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        scanningContentView.translatesAutoresizingMaskIntoConstraints = false
        resultContentView.translatesAutoresizingMaskIntoConstraints = false
        directSearchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            grabberView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            grabberView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabberView.widthAnchor.constraint(equalToConstant: 36),
            grabberView.heightAnchor.constraint(equalToConstant: 5),

            // 헤더 박스: 그래버서 6, 좌우 패딩 동일(17), 높이 44
            headerBox.topAnchor.constraint(equalTo: grabberView.bottomAnchor, constant: 6),
            headerBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            headerBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            headerBox.heightAnchor.constraint(equalToConstant: 44),

            // X — 박스 왼쪽
            closeButton.leadingAnchor.constraint(equalTo: headerBox.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: headerBox.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            // 타이틀 — 박스 중앙
            titleLabel.centerXAnchor.constraint(equalTo: headerBox.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerBox.centerYAnchor),

            scanningContentView.topAnchor.constraint(equalTo: headerBox.bottomAnchor, constant: 20),
            scanningContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanningContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanningContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            resultContentView.topAnchor.constraint(equalTo: headerBox.bottomAnchor, constant: 20),
            resultContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultContentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 직접 검색 — safe area 바로 위, 중앙
            directSearchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            directSearchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        resultContentView.retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        directSearchButton.addTarget(self, action: #selector(directSearchTapped), for: .touchUpInside)
    }

    @objc func directSearchTapped() {
        // TODO: 직접(수동) 책 검색 화면 연결 (검색 플로우 미구현)
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
                    #if DEBUG
                    if LaunchArguments.mockBookNotFound { throw NetworkError.noData }   // QA: 책 조회 실패 강제
                    #endif
                    // 책 조회(Kakao)는 필수 — 실패하면 바깥 catch → .failed (재시도/직접검색)
                    let book = try await ISBNLookupService.shared.lookupBook(isbn: isbn)
                    guard !Task.isCancelled else { return }

                    // Gemini 환경추천은 부가 — 실패해도 기본 환경으로 진행하고 미리보기에서 토스트 안내
                    var lighting = LightingConfig.default
                    var music: MusicCategory = .warm
                    var conversations: [ConversationProfile] = []
                    var fallbackMessage: String? = nil
                    do {
                        #if DEBUG
                        if LaunchArguments.mockGemini429 { throw NetworkError.invalidResponse(statusCode: 429) }
                        if LaunchArguments.mockGeminiServerError { throw NetworkError.invalidResponse(statusCode: 500) }
                        #endif
                        async let envTask = self.geminiService.generateLightingAndMusic(for: book)
                        async let questionsTask = self.geminiService.generateQuestions(for: book, age: UserData.childAge)
                        let (env, conversationDTOs) = try await (envTask, questionsTask)
                        lighting = env.lighting
                        music = env.musicCategory
                        conversations = conversationDTOs.map { $0.toProfile() }
                    } catch is CancellationError {
                        return
                    } catch {
                        fallbackMessage = ReadingViewModel.aiFallbackNotice(for: error)
                        print("[Gemini] 추천 실패 → 기본 환경 폴백: \(error.localizedDescription)")
                    }
                    guard !Task.isCancelled else { return }

                    self.fetchedBook = book
                    self.preparedEnvironment = PreparedEnvironment(
                        lighting: lighting,
                        musicCategory: music,
                        conversations: conversations,
                        aiFallbackMessage: fallbackMessage
                    )

                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed < 2.0 {
                        try await Task.sleep(nanoseconds: UInt64((2.0 - elapsed) * 1_000_000_000))
                    }
                    guard !Task.isCancelled else { return }
                    self.state = .success
                } catch is CancellationError {
                    return
                } catch {
                    // 책 조회 실패 → 인식 실패 (기존 재시도/직접검색 흐름)
                    let elapsed = Date().timeIntervalSince(startTime)
                    if elapsed < 2.0 {
                        try? await Task.sleep(nanoseconds: UInt64((2.0 - elapsed) * 1_000_000_000))
                    }
                    guard !Task.isCancelled else { return }
                    self.state = .failed
                }
            }

        case .success:
            // 체크표시/완료 애니메이션 없이 바로 다음 페이지로
            guard let book = fetchedBook else { return }
            let env = preparedEnvironment
            dismiss(animated: true) {
                if self.isRestarting {
                    self.coordinator?.replaceReadingFlow(with: book, environment: env)
                } else {
                    // BookProfile 단계를 건너뛰고, 인식중에 받아둔 환경으로 바로 미리보기 진입
                    self.coordinator?.showReading(book: book, environment: env)
                }
            }

        case .failed:
            animator.showFailed()
        }
    }

    func updateVisibility(for state: ScannerState) {
        scanningContentView.alpha = state == .scanning ? 1 : 0
        scanningContentView.isHidden = state != .scanning

        // 직접 검색은 스캐닝 상태에서만
        directSearchButton.isHidden = state != .scanning

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

