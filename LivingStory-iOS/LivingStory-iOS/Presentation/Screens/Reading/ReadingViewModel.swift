import Foundation

enum ReadingState {
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

    private(set) var conversations: [Conversation] = []
    private(set) var musicCategory: MusicCategory?
    private(set) var lightingConfig: LightingConfig?
    private(set) var errorMessage: String?

    private let geminiService: GeminiService
    private let audioPlayerService: AudioPlayerService
    private var timerTask: Task<Void, Never>?
    private var hasStarted = false

    init(
        book: BookProfileModel,
        geminiService: GeminiService = GeminiService(),
        audioPlayerService: AudioPlayerService = AudioPlayerService()
    ) {
        self.book = book
        self.geminiService = geminiService
        self.audioPlayerService = audioPlayerService
    }

    deinit {
        audioPlayerService.stop()
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
            conversations = environment.toDomainConversations()

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
