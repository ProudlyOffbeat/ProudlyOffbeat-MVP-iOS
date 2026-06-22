import Foundation

enum ReadingState: Sendable {
    case setting
    case reading
    case error
}

@MainActor
@Observable
final class ReadingViewModel {

    // TODO: 아이 나이 입력(설정) 구현 후 UserData에서 읽어오도록 교체. 현재는 임시 상수.
    private static let childAge = 6

    let book: BookProfileModel
    private(set) var state: ReadingState = .setting
    private(set) var isLightingReady = false
    private(set) var isMusicPlaying = false
    private(set) var elapsedSeconds: Int = 0

    private(set) var conversations: [ConversationProfile] = []
    private(set) var musicCategory: MusicCategory?
    private(set) var lightingConfig: LightingConfig?
    private(set) var errorMessage: String?
    
    private(set) var volume: Float = 1.0
    private(set) var lastAction: String?
    private(set) var lastLatencyMs: Int?
    private(set) var latencyHistory: [Int] = []
    private(set) var geminiRecommendedLighting: LightingConfig?
    private var pendingLightingTask: Task<Void, Never>?
    private var pendingLightingConfig: LightingConfig?
    private var lastSentTime: Date = .distantPast
    private let brightnessThrottle: TimeInterval = 0.2   // 200ms (안정, 실기기 검증됨)
    private let colorThrottle: TimeInterval = 0.25      // 250ms (H + S 2 characteristic)

    // 반응시간 통계
    var avgLatencyMs: Int? {
        guard !latencyHistory.isEmpty else { return nil }
        return latencyHistory.reduce(0, +) / latencyHistory.count
    }
    var maxLatencyMs: Int? { latencyHistory.max() }
    var minLatencyMs: Int? { latencyHistory.min() }

    private(set) var readingSession: ReadingSessionProfile?

    private let geminiService: GeminiService
    private let audioPlayerService: AudioPlayerService
    private let bookRepository: BookRepositoryProtocol
    private let sessionRepository: ReadingSessionRepositoryProtocol
    private let lightingController: (any LightingControllable)?
    private var timerTask: Task<Void, Never>?
    private var startTime: Date?
    private var hasStarted = false

    init(
        book: BookProfileModel,
        geminiService: GeminiService? = nil,
        audioPlayerService: AudioPlayerService? = nil,
        bookRepository: BookRepositoryProtocol? = nil,
        sessionRepository: ReadingSessionRepositoryProtocol? = nil,
        lightingController: (any LightingControllable)? = nil
    ) {
        self.book = book
        self.geminiService = geminiService ?? GeminiService()
        self.audioPlayerService = audioPlayerService ?? AudioPlayerService()
        self.bookRepository = bookRepository ?? BookRepository()
        self.sessionRepository = sessionRepository ?? ReadingSessionRepository()
        self.lightingController = lightingController
    }

    // MARK: - App Lifecycle

    func pause() {
        guard state == .reading else { return }
        audioPlayerService.pause()
    }

    func resume() {
        guard state == .reading else { return }
        audioPlayerService.resume()
    }

#if DEBUG
    /// SwiftUI 프리뷰 전용 — 원하는 상태/추천값으로 즉시 구성 (네트워크 호출 없음)
    convenience init(
        previewBook: BookProfileModel,
        state: ReadingState,
        lightingConfig: LightingConfig? = nil,
        musicCategory: MusicCategory? = nil,
        conversations: [ConversationProfile] = []
    ) {
        self.init(book: previewBook, lightingController: MockLightingController())
        self.state = state
        self.lightingConfig = lightingConfig
        self.musicCategory = musicCategory
        self.conversations = conversations
        self.hasStarted = true // startSetup() 조기 종료 → Gemini 호출 차단
    }
#endif

    // MARK: - Public

    func startSetup() async {
        guard !hasStarted else {
            print("[Gemini] 중복 호출 차단됨")
            return
        }
        hasStarted = true
        print("[Gemini] API 요청 시작 (1회)")

        // 세팅 중 밝기 펄스 시작 (UI 펄스와 동기)
        if let controller = lightingController {
            await controller.startBrightnessPulse(base: 80, range: 50)
        }

        do {
            // 2-호출 병렬: 질문(그라운딩 ON)·조명음악(JSON 강제)을 동시에 띄워 한 번에 await.
            async let questionsTask = geminiService.generateQuestions(for: book, age: Self.childAge)
            async let environmentTask = geminiService.generateLightingAndMusic(for: book)
            let (conversationDTOs, environment) = try await (questionsTask, environmentTask)

            musicCategory = environment.musicCategory
            lightingConfig = environment.lighting
            geminiRecommendedLighting = environment.lighting
            conversations = conversationDTOs.map { $0.toProfile() }

            print("[Gemini] 음악: \(environment.musicCategory.rawValue)")
            print("[Gemini] 조명: H\(environment.lighting.hue) S\(environment.lighting.saturation) B\(environment.lighting.brightness)")
            print("[Gemini] 대화 주제: \(conversationDTOs.count)개")

            // 펄스 중지 → Gemini 색상 적용
            AppLightingService.shared.isReadingActive = true
            if let controller = lightingController, let config = lightingConfig {
                await controller.stopBrightnessPulse()
                do {
                    try await controller.applyLightingWithPowerOn(config)
                    UserData.lastLightingConfig = config
                    print("[Lighting] 조명 설정 완료")
                } catch {
                    print("[Lighting] 조명 설정 실패: \(error.localizedDescription)")
                }
            }
            isLightingReady = true // 조명 실패해도 독서 진행

            // AVFoundation 음악 재생
            if let category = musicCategory {
                do {
                    try audioPlayerService.play(category: category)
                    isMusicPlaying = true
                } catch {
                    isMusicPlaying = true // 음원 실패해도 독서 진행
                }
            } else {
                isMusicPlaying = true
            }

            if isLightingReady && isMusicPlaying {
                state = .reading
                startTime = Date()
                startTimer()
            }
        } catch {
            if let controller = lightingController {
                await controller.stopBrightnessPulse()
            }
            print("[Gemini] 오류: \(error)")
            errorMessage = "환경세팅에 오류가 발생했어요!"
            state = .error
        }
    }

    func stopReading() {
        timerTask?.cancel()
        timerTask = nil
        audioPlayerService.stop()
        isMusicPlaying = false
        AppLightingService.shared.isReadingActive = false

        // 펄스 중지 (조명 리셋 안 함 — 질문 화면/다음 진입까지 마지막 조명 유지)
        if let controller = lightingController {
            Task { await controller.stopBrightnessPulse() }
        }

        guard let startTime else { return }

        let endTime = Date()
        let durationSeconds = Int(endTime.timeIntervalSince(startTime))

        let session = ReadingSessionProfile(
            id: UUID(),
            startTime: startTime,
            endTime: endTime,
            durationSeconds: durationSeconds,
            bookProfile: book,
            musicCategory: musicCategory,
            lighting: lightingConfig ?? .default,
            conversations: conversations,
            memo: nil,
            createdAt: Date()
        )

        readingSession = session

        do {
            try bookRepository.saveBook(book)
            try sessionRepository.saveSession(session, bookISBN: book.isbn)
        } catch {
            print("[Gemini] 세션 저장 실패: \(error)")
        }
    }

    func retry() async {
        errorMessage = nil
        hasStarted = false
        state = .setting
        await startSetup()
    }
    
    func setVolume(_ value: Float) {
        audioPlayerService.setVolume(value)
        volume = value
        recordAction("볼륨 \(Int(value * 100)) %", latencyMs: 0 )
    }
    
    func changeMusic(to category: MusicCategory) {
        let start = Date()
        do {
            try audioPlayerService.play(category: category)
            audioPlayerService.setVolume(volume)
            musicCategory = category
            isMusicPlaying = true
            let ms = Int(Date().timeIntervalSince(start)*1000)
            recordAction("음악 -> \(category.rawValue)", latencyMs: ms)
        } catch {
            recordAction("음악 실패 :(error.localizedDescription)", latencyMs: nil)
        }
    }
    
    /// 드래그 중 — 쓰로틀 (밝기 100ms / 색상 250ms)
    func updateLighting(hue: Int? = nil, saturation: Int? = nil, brightness: Int? = nil) {
        let current = lightingConfig ?? .default
        let newConfig = LightingConfig(
            hue: hue ?? current.hue,
            saturation: saturation ?? current.saturation,
            brightness: brightness ?? current.brightness
        )
        lightingConfig = newConfig
        pendingLightingConfig = newConfig

        // 색상 변경이면 느린 쓰로틀, 밝기만이면 빠른 쓰로틀
        let isColorChange = hue != nil || saturation != nil
        let interval = isColorChange ? colorThrottle : brightnessThrottle

        let elapsed = Date().timeIntervalSince(lastSentTime)

        if elapsed >= interval {
            // Leading: 바로 전송
            lastSentTime = Date()
            pendingLightingConfig = nil
            pendingLightingTask?.cancel()
            pendingLightingTask = nil
            Task { [weak self] in
                await self?.sendLighting(newConfig)
            }
        } else if pendingLightingTask == nil {
            // Trailing: 다음 틱까지 대기 후 최신값 전송
            let delay = interval - elapsed
            pendingLightingTask = Task { [weak self] in
                try? await Task.sleep(for: .milliseconds(Int(delay * 1000)))
                guard !Task.isCancelled, let self, let config = self.pendingLightingConfig else { return }
                self.lastSentTime = Date()
                self.pendingLightingConfig = nil
                self.pendingLightingTask = nil
                await self.sendLighting(config)
            }
        }
        // else: 이미 예약됨 → pendingLightingConfig만 최신값 유지
    }

    /// 손 뗐을 때 — 쓰로틀 취소 + 즉시 전송 (슬라이더 Release)
    func commitLighting() {
        guard let config = lightingConfig else { return }
        pendingLightingTask?.cancel()
        pendingLightingTask = nil
        pendingLightingConfig = nil
        lastSentTime = Date()
        Task { [weak self] in
            await self?.sendLighting(config)
        }
    }

    /// 프리셋 탭 — 디바운스 없이 즉시 전송 (1 write)
    func applyPreset(_ preset: LightingPreset) {
        let newConfig = preset.config
        lightingConfig = newConfig
        pendingLightingTask?.cancel()
        Task { [weak self] in
            await self?.sendLighting(newConfig)
        }
    }

    /// Gemini 추천 조명 재적용
    func applyGeminiRecommended() {
        guard let config = geminiRecommendedLighting else { return }
        lightingConfig = config
        pendingLightingTask?.cancel()
        Task { [weak self] in
            await self?.sendLighting(config)
        }
    }

    /// 반응시간 통계 초기화
    func clearLatencyHistory() {
        latencyHistory.removeAll()
    }

    private func sendLighting(_ config: LightingConfig) async {
        guard let controller = lightingController else { return }
        let start = Date()
        do {
            try await controller.applyLighting(config)
            UserData.lastLightingConfig = config
            let ms = Int(Date().timeIntervalSince(start) * 1000)
            recordAction(
                "조명 H\(config.hue) S\(config.saturation) B\(config.brightness)",
                latencyMs: ms
            )
        } catch {
            recordAction("조명 실패: \(error.localizedDescription)", latencyMs: nil)
        }
    }
    
    private func recordAction(_ text: String, latencyMs: Int?) {
        lastAction = text
        lastLatencyMs = latencyMs
        if let ms = latencyMs {
            latencyHistory.append(ms)
            // 최근 50개만 유지 (메모리 제한)
            if latencyHistory.count > 50 {
                latencyHistory.removeFirst(latencyHistory.count - 50)
            }
        }
    }
    
    // MARK: - Private

    private func startTimer() {
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self?.elapsedSeconds += 1
            }
        }
    }
}
