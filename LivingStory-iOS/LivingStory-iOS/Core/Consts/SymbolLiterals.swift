//
//  SymbolLiterals.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 SF Symbols 관리
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  사용법 (SwiftUI):
//  ```swift
//  Image(.home)
//  Image(.scanner)
//  ```
//
//  사용법 (UIKit):
//  ```swift
//  let image = UIImage(.home)
//  button.setImage(UIImage(.scanner), for: .normal)
//  ```
//
//  SF Symbols 앱에서 아이콘 이름 확인:
//  https://developer.apple.com/sf-symbols/
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI
import UIKit

// MARK: - Symbol Enum

enum SymbolLiterals: String {

    // MARK: - Tab Bar

    case home = "house.fill"
    case book = "book.fill"
    case person = "person.fill"
    case settings = "gearshape"

    // MARK: - Navigation

    case back = "chevron.left"
    case forward = "chevron.right"
    case close = "xmark"
    case menu = "line.3.horizontal"

    // MARK: - Actions

    case barcode = "barcode"
    case scanner = "barcode.viewfinder"
    case camera = "camera.fill"
    case flashlightOff = "flashlight.off.fill"
    case flashlightOn = "flashlight.on.fill"
    case search = "magnifyingglass"
    case plus = "plus"
    case edit = "pencil"
    case delete = "trash"
    case share = "square.and.arrow.up"

    // MARK: - HomeKit / Devices

    case lightbulb = "lightbulb.fill"
    case speaker = "speaker.wave.2.fill"
    case speakerOff = "speaker.wave.2"
    case ellipsis = "ellipsis"

    // MARK: - Status

    case checkmark = "checkmark"
    case checkmarkCircle = "checkmark.circle.fill"
    case warning = "exclamationmark.triangle.fill"
    case error = "xmark.circle.fill"
    case info = "info.circle.fill"

    // MARK: - Statistics

    case calendar = "calendar"
    case books = "books.vertical.fill"
    case clock = "clock"

    // MARK: - Reading

    case musicNoteHouse = "music.note.house.fill"
    case play = "play.fill"
    case pause = "pause.fill"
    case stop = "stop.fill"
    case timer = "timer"
    case moon = "moon.fill"
    case sun = "sun.max.fill"
}

// MARK: - SwiftUI Extension

extension Image {
    init(_ symbol: SymbolLiterals) {
        self.init(systemName: symbol.rawValue)
    }
}

// MARK: - UIKit Extension

extension UIImage {
    convenience init?(_ symbol: SymbolLiterals) {
        self.init(systemName: symbol.rawValue)
    }
}
