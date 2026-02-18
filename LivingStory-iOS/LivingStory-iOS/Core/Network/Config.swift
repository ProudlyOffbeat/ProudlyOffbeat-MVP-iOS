//
//  Config.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/18/26.
//

import Foundation

enum Config {
    static var kakaoRESTAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as? String,
              !key.isEmpty else {
            fatalError("KAKAO_REST_API_KEY not found in Info.plist")
        }
        return key
    }
}
