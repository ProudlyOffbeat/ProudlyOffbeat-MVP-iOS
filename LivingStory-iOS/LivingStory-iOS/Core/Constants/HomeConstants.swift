//
//  HomeConstants.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 1/19/26.
//

enum HomeConstants {
    enum DeviceType: String {
        case light = "LightBulb"
        case speaker = "Speaker"
    }
    
    enum Config {
        static let scanTimeOut: TimeInterval = 10.0
    }
}
