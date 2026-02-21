import Foundation

enum ReadingState: Sendable {
    case setting
    case reading
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

    private(set) var readingSession: ReadingSessionProfile?

    private let geminiService: GeminiService
    private let audioPlayerService: AudioPlayerService
    private let bookRepository: BookRepositoryProtocol
    private let sessionRepository: ReadingSessionRepositoryProtocol
    private var timerTask: Task<Void, Never>?
    private var startTime: Date?
    private var hasStarted = false

    init(
        book: BookProfileModel,
        geminiService: GeminiService? = nil,
        audioPlayerService: AudioPlayerService? = nil,
        bookRepository: BookRepositoryProtocol? = nil,
        sessionRepository: ReadingSessionRepositoryProtocol? = nil
    ) {
        self.book = book
        self.geminiService = geminiService ?? GeminiService()
        self.audioPlayerService = audioPlayerService ?? AudioPlayerService()
        self.bookRepository = bookRepository ?? BookRepository()
        self.sessionRepository = sessionRepository ?? ReadingSessionRepository()
    }

    // MARK: - Public

    func startSetup() async {
        guard !hasStarted else {
            print("[Gemini] 중복 호출 차단됨")
            return
        }
        hasStarted = true
        print("[Gemini] API 요청 시작 (1회)")

        do {
            #if DEBUG
            let environment = ReadingEnvironment.mock
            #else
            let environment = try await geminiService.generateReadingEnvironment(for: book)
            #endif

            musicCategory = environment.musicCategory
            lightingConfig = environment.lighting
            conversations = environment.toConversationProfiles()

            print("[Gemini] 음악: \(environment.musicCategory.rawValue)")
            print("[Gemini] 조명: H\(environment.lighting.hue) S\(environment.lighting.saturation) B\(environment.lighting.brightness)")
            print("[Gemini] 대화 주제: \(environment.conversations.count)개")

            // TODO: HomeKit 조명 설정
            isLightingReady = true

            // AVFoundation 음악 재생
            if let category = musicCategory {
                do {
                    try audioPlayerService.play(category: category)
                    isMusicPlaying = true
                    print("[Audio] \(category.rawValue) 재생 시작")
                } catch {
                    print("[Audio] 재생 실패: \(error.localizedDescription)")
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
            errorMessage = error.localizedDescription
            print("[Gemini] 오류: \(error)")
        }
    }

    func stopReading() {
        timerTask?.cancel()
        timerTask = nil
        audioPlayerService.stop()
        isMusicPlaying = false

        guard let startTime else { return }

        let endTime = Date()
        let durationMinutes = Int(endTime.timeIntervalSince(startTime) / 60)

        let session = ReadingSessionProfile(
            id: UUID(),
            startTime: startTime,
            endTime: endTime,
            durationMinutes: durationMinutes,
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
            print("[Session] 독서 기록 저장 - \(durationMinutes)분")
        } catch {
            print("[Session] 저장 실패: \(error)")
        }

        print("[Audio] 재생 중단")
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

#if DEBUG
extension ReadingViewModel {
    func setState(_ state: ReadingState) {
        self.state = state
    }
}
#endif
