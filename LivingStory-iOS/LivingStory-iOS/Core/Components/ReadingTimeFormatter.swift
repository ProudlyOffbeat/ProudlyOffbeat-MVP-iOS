//
//  ReadingTimeFormatter.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/22/26.
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ⏱ 독서 시간 포맷터
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  사용법:
//  ```swift
//  let text = ReadingTimeFormatter.format(totalSeconds: 3661)
//  // → "1시간 1분 1초"
//  ```
//

import Foundation

enum ReadingTimeFormatter {

    /// 초 단위를 "X시간 Y분 Z초" 형식으로 변환
    static func format(totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var parts: [String] = []

        if hours > 0 {
            parts.append("\(hours)\(StringLiterals.My.hourUnit)")
        }
        if minutes > 0 {
            parts.append("\(minutes)\(StringLiterals.My.minuteUnit)")
        }
        if seconds > 0 || parts.isEmpty {
            parts.append("\(seconds)\(StringLiterals.My.secondUnit)")
        }

        return parts.joined(separator: " ")
    }
}
