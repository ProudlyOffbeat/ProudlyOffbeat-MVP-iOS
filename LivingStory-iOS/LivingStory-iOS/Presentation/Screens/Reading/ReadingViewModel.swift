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

    private var timerTask: Task<Void, Never>?

    init(book: BookProfileModel) {
        self.book = book
    }

    // MARK: - Public

    func startSetup() async {
        // TODO: Gemini API → hue 값 + 음악 추천
        // TODO: HomeKit 조명 설정
        isLightingReady = true

        // TODO: AVFoundation 음악 재생
        isMusicPlaying = true

        if isLightingReady && isMusicPlaying {
            state = .reading
            startTimer()
        }
    }

    func stopReading() {
        timerTask?.cancel()
        timerTask = nil
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
