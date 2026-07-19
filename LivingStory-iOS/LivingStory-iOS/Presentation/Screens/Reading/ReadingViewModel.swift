import Foundation

enum ReadingState: Sendable {
    case setting
    case preview   // 환경 세팅 완료 → 미리보기(조명·음악 추천 확인/조절) → 독서 시작 전
    case reading
    case error
}

/// 스캐너 인식중에 미리 받아온 환경 추천 (조명·음악·대화).
/// 이게 있으면 ReadingViewModel은 Gemini를 다시 호출하지 않고 바로 미리보기로 진입한다.
struct PreparedEnvironment: Sendable {
    let lighting: LightingConfig
    let musicCategory: MusicCategory
    let conversations: [ConversationProfile]
    /// AI 추천 실패로 기본 환경으로 폴백했을 때의 안내 문구 (nil = 정상 추천)
    var aiFallbackMessage: String? = nil
}

@MainActor
@Observable
final class ReadingViewModel {

    let book: BookProfileModel
    private(set) var state: ReadingState = .setting
    private(set) var isLightingReady = false
    private(set) var isMusicPlaying = false
    private(set) var elapsedSeconds: Int = 0

    private(set) var conversations: [ConversationProfile] = []
    private(set) var musicCategory: MusicCategory?
    private(set) var lightingConfig: LightingConfig?
    private(set) var errorMessage: String?
    /// AI 추천 실패 시 미리보기에 띄울 토스트 문구 (nil = 표시 안 함)
    var aiFallbackMessage: String?

    private(set) var volume: Float = 1.0
    private(set) var lastAction: String?
    private(set) var lastLatencyMs: Int?
    private(set) var latencyHistory: [Int] = []
    private(set) var geminiRecommendedLighting: LightingConfig?
    /// Gemini가 처음 추천한 음악 — 사용자가 다른 곡을 골라도 유지(✨ 배지·기본 추천 표시용)
    private(set) var geminiRecommendedMusic: MusicCategory?
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
    /// 스캐너에서 미리 받아온 환경 추천 (있으면 Gemini 재호출 생략)
    private let preparedEnvironment: PreparedEnvironment?
    private var timerTask: Task<Void, Never>?
    private var startTime: Date?
    private var hasStarted = false

    init(
        book: BookProfileModel,
        geminiService: GeminiService? = nil,
        audioPlayerService: AudioPlayerService? = nil,
        bookRepository: BookRepositoryProtocol? = nil,
        sessionRepository: ReadingSessionRepositoryProtocol? = nil,
        lightingController: (any LightingControllable)? = nil,
        preparedEnvironment: PreparedEnvironment? = nil
    ) {
        self.book = book
        self.geminiService = geminiService ?? GeminiService()
        self.audioPlayerService = audioPlayerService ?? AudioPlayerService()
        self.bookRepository = bookRepository ?? BookRepository()
        self.sessionRepository = sessionRepository ?? ReadingSessionRepository()
        self.lightingController = lightingController
        self.preparedEnvironment = preparedEnvironment
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
        self.geminiRecommendedMusic = musicCategory
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

        // 스캐너 인식중에 이미 환경 추천을 받아온 경우: Gemini 생략, 바로 미리보기 적용
        if let prepared = preparedEnvironment {
            await applyPreparedEnvironment(prepared)
            return
        }

        print("[Gemini] API 요청 시작 (1회)")

        // 세팅 중 밝기 펄스 시작 (UI 펄스와 동기)
        if let controller = lightingController {
            await controller.startBrightnessPulse(base: 80, range: 50)
        }

        // Gemini 추천 — 실패해도 기본 환경으로 진행(책은 이미 확보됨). 실패 시 미리보기 토스트로 안내.
        var lighting = LightingConfig.default
        var music: MusicCategory = .warm
        var convos: [ConversationProfile] = []
        do {
            async let questionsTask = geminiService.generateQuestions(for: book, age: UserData.childAge)
            async let environmentTask = geminiService.generateLightingAndMusic(for: book)
            let (conversationDTOs, environment) = try await (questionsTask, environmentTask)
            lighting = environment.lighting
            music = environment.musicCategory
            convos = conversationDTOs.map { $0.toProfile() }
            print("[Gemini] 추천 완료: 음악 \(music.rawValue), 대화 \(convos.count)개")
        } catch {
            print("[Gemini] 추천 실패 → 기본 환경 폴백: \(error.localizedDescription)")
            aiFallbackMessage = Self.aiFallbackNotice(for: error)   // 에러별 토스트 문구
        }

        musicCategory = music
        geminiRecommendedMusic = music
        lightingConfig = lighting
        geminiRecommendedLighting = lighting
        conversations = convos

        // 펄스 중지 → 최종(추천 또는 기본) 색상 적용
        AppLightingService.shared.isReadingActive = true
        if let controller = lightingController {
            await controller.stopBrightnessPulse()
            try? await controller.applyLightingWithPowerOn(lighting)
            UserData.lastLightingConfig = lighting
        }
        isLightingReady = true

        try? audioPlayerService.play(category: music)
        isMusicPlaying = true

        state = .preview
    }

    /// AI(Gemini) 추천 실패 → 에러별 사용자 안내 문구 (GeminiError.errorDescription 활용: 429·서버코드·네트워크 등)
    static func aiFallbackNotice(for error: Error) -> String {
        if let g = error as? GeminiError, let desc = g.errorDescription {
            return desc
        }
        return "AI 추천을 불러오지 못했어요. 잠시 후 다시 시도해주세요."
    }

    /// 미리보기에서 "다시 추천받기" — Gemini 재호출 후 조명·음악·대화 갱신. 재실패 시 다시 안내.
    func retryAIRecommendation() async {
        aiFallbackMessage = nil
        do {
            async let questionsTask = geminiService.generateQuestions(for: book, age: UserData.childAge)
            async let environmentTask = geminiService.generateLightingAndMusic(for: book)
            let (conversationDTOs, environment) = try await (questionsTask, environmentTask)
            lightingConfig = environment.lighting
            musicCategory = environment.musicCategory
            geminiRecommendedLighting = environment.lighting
            geminiRecommendedMusic = environment.musicCategory
            conversations = conversationDTOs.map { $0.toProfile() }
            if let controller = lightingController {
                try? await controller.applyLightingWithPowerOn(environment.lighting)
            }
            try? audioPlayerService.play(category: environment.musicCategory)
        } catch {
            aiFallbackMessage = Self.aiFallbackNotice(for: error)
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
            // 오늘 독서 완료 → 오늘의 재알림/스트릭경고 취소 + 재스케줄
            Task { await ReadingNotificationScheduler.shared.onDidRead() }
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

    /// 스캐너에서 미리 받아온 환경을 적용하고 바로 미리보기로 (조명 실시간 반영·음악 재생).
    /// UserDefaults 저장은 여기서 하지 않고, "책 환경 세팅하기"(startReading) 시점에 확정 저장한다.
    private func applyPreparedEnvironment(_ prepared: PreparedEnvironment) async {
        musicCategory = prepared.musicCategory
        geminiRecommendedMusic = prepared.musicCategory
        lightingConfig = prepared.lighting
        geminiRecommendedLighting = prepared.lighting
        conversations = prepared.conversations
        aiFallbackMessage = prepared.aiFallbackMessage   // AI 추천 실패 시 토스트 문구

        // 미리보기 즉시 노출 (scan→미리보기 사이 "세팅중" 화면 제거). 조명/음악은 미리보기 뜬 뒤 적용.
        state = .preview

        AppLightingService.shared.isReadingActive = true
        if let controller = lightingController {
            try? await controller.applyLightingWithPowerOn(prepared.lighting)
        }
        isLightingReady = true

        try? audioPlayerService.play(category: prepared.musicCategory)
        isMusicPlaying = true
    }

    /// 환경 미리보기 → "책 환경 세팅하기": 세팅중(홈앱 최종 적용 · UserDefaults 저장) → 독서 시작.
    func startReading() async {
        guard state == .preview else { return }
        state = .setting   // "환경 세팅중..." (화면 글로우 + 물리 조명 펄스)

        // 물리 조명도 세팅중엔 펄스 (화면 펄스와 동기) — 최소 3초 고정
        if let controller = lightingController {
            await controller.startBrightnessPulse(base: 80, range: 50)
        }
        try? await Task.sleep(for: .seconds(3))
        if let controller = lightingController {
            await controller.stopBrightnessPulse()
        }

        // 펄스 종료 후 최종 색상 적용 + UserDefaults에 확정 저장 (다음 실행 복원용)
        if let config = lightingConfig {
            if let controller = lightingController {
                try? await controller.applyLightingWithPowerOn(config)
            }
            UserData.lastLightingConfig = config
        }

        state = .reading
        startTime = Date()
        startTimer()
    }

    /// 환경 미리보기 취소(뒤로가기) — 음악 정지·타이머 해제.
    func cancelPreview() {
        audioPlayerService.stop()
        isMusicPlaying = false
        timerTask?.cancel()
        AppLightingService.shared.isReadingActive = false
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

    /// 음악 조정 시트 진입 — 선택 상태 유지 + 재생 일시정지.
    func pauseMusicForAdjust() {
        guard isMusicPlaying else { return }
        audioPlayerService.pause()
        isMusicPlaying = false
    }

    /// 현재 선택곡 재생/일시정지 토글 (미니플레이어·선택 행 버튼).
    func toggleMusicPlayback() {
        if isMusicPlaying {
            audioPlayerService.pause()
            isMusicPlaying = false
            recordAction("음악 일시정지", latencyMs: 0)
        } else {
            audioPlayerService.resume()
            isMusicPlaying = true
            recordAction("음악 재생", latencyMs: 0)
        }
    }

    /// 음악 조정 시트 — 곡 선택. 같은 곡이면 재생/일시정지 토글, 다른 곡이면 그 곡으로 전환·재생.
    func selectMusic(_ category: MusicCategory) {
        if category == musicCategory {
            toggleMusicPlayback()
        } else {
            changeMusic(to: category)
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
