//
//  AudioPlayerService.swift
//  LivingStory-iOS
//

import AVFoundation

final class AudioPlayerService {

    private var player: AVAudioPlayer?

    deinit {
        stop()
    }

    func play(category: MusicCategory) throws {
        guard let url = Bundle.main.url(
            forResource: category.audioFileName,
            withExtension: "mp3"
        ) else {
            throw AudioPlayerError.fileNotFound(category.audioFileName)
        }

        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        player = try AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    var isPlaying: Bool {
        player?.isPlaying ?? false
    }
}

enum AudioPlayerError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "오디오 파일을 찾을 수 없습니다: \(name).mp3"
        }
    }
}
