//
//  MusicCategory.swift
//  LivingStory-iOS
//

import Foundation

enum MusicCategory: String, Codable, CaseIterable {
    case nature = "자연의소리"
    case classical = "클래식"
    case nurseryRhyme = "동요"
    case fantasy = "판타지"
    case calmPiano = "잔잔한피아노"
    case musicBox = "오르골"
    case jazz = "재즈"
    case oceanRain = "바다와비"
    case forest = "숲속"
    case space = "우주"

    /// 오디오 파일명 (추후 실제 에셋으로 교체)
    var audioFileName: String {
        switch self {
        case .nature: return "nature_sounds"
        case .classical: return "classical"
        case .nurseryRhyme: return "nursery_rhyme"
        case .fantasy: return "fantasy"
        case .calmPiano: return "calm_piano"
        case .musicBox: return "music_box"
        case .jazz: return "jazz"
        case .oceanRain: return "ocean_rain"
        case .forest: return "forest"
        case .space: return "space"
        }
    }

    /// 프롬프트에 사용할 카테고리 목록 문자열
    static var promptList: String {
        allCases.map { $0.rawValue }.joined(separator: ", ")
    }
}
