//
//  AudioPlayerService.swift
//  LivingStory-iOS
//

import AVFoundation

@MainActor
final class AudioPlayerService {

    // MARK: - Constants

    static let defaultFadeDuration: TimeInterval = 2.0
    private static let basicMusicFileName = "NaruBasicMusic"

    // MARK: - Properties

    private var player: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?

    // MARK: - Category Music

    func play(category: MusicCategory, fadeIn: Bool = false) throws {
        guard let url = Bundle.main.url(
            forResource: category.audioFileName,
            withExtension: "mp3"
        ) else {
            throw AudioPlayerError.fileNotFound(category.audioFileName)
        }

        try setupAudioSession()
        player = try AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1

        if fadeIn {
            player?.volume = 0
            player?.play()
            player?.setVolume(1.0, fadeDuration: Self.defaultFadeDuration)
        } else {
            player?.play()
        }
    }

    // MARK: - Basic Background Music

    func playBasicMusic(fadeIn: Bool = true) throws {
        guard let url = Bundle.main.url(
            forResource: Self.basicMusicFileName,
            withExtension: "mp3"
        ) else {
            throw AudioPlayerError.fileNotFound(Self.basicMusicFileName)
        }

        try setupAudioSession()
        player = try AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1

        if fadeIn {
            player?.volume = 0
            player?.play()
            player?.setVolume(1.0, fadeDuration: Self.defaultFadeDuration)
        } else {
            player?.play()
        }
    }

    // MARK: - Fade & Stop

    /// 페이드아웃 후 정지. completion은 페이드 완료 후 호출.
    func fadeOutAndStop(
        duration: TimeInterval = defaultFadeDuration,
        completion: (() -> Void)? = nil
    ) {
        guard let player, player.isPlaying else {
            completion?()
            return
        }

        player.setVolume(0, fadeDuration: duration)

        fadeTask?.cancel()
        fadeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            self?.player?.stop()
            self?.player = nil
            completion?()
        }
    }

    func stop() {
        fadeTask?.cancel()
        fadeTask = nil
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }

    // MARK: - Private

    private func setupAudioSession() throws {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
    }
}

enum AudioPlayerError: LocalizedError, Sendable {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "오디오 파일을 찾을 수 없습니다: \(name).mp3"
        }
    }
}
