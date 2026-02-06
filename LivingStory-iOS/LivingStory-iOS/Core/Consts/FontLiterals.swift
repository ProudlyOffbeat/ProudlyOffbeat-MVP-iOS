//
//  AppTypography.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 앱 타이포그래피 시스템
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  🧑‍💻 UIKit 사용법:
//  ```swift
//  label.font = .title1
//  label.font = .body
//  ```
//
//  📱 SwiftUI 사용법:
//  ```swift
//  Text("Hello")
//      .font(.title1)
//  ```
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit
import SwiftUI

// UIKit Extension

extension UIFont {
    // MARK: LaregeTitle
    static let largeTitleEmphasized: UIFont = .systemFont(ofSize: 34, weight: .bold)
    
    // MARK: Title
    static let title1Emphasized: UIFont = .systemFont(ofSize: 28, weight: .bold)
    static let title2Emphasized: UIFont = .systemFont(ofSize: 22, weight: .bold)
    static let title3Emphasized: UIFont = .systemFont(ofSize: 20, weight: .semibold)
    
    // MARK: Headline / Subheadline
    static let headlineRegular: UIFont = .systemFont(ofSize: 17, weight: .semibold )
    static let subhaedlineRegular: UIFont = .systemFont(ofSize: 15, weight: .regular )
    static let subheadlienRegular: UIFont = .systemFont(ofSize: 15, weight: .semibold )
    
    // MARK: Body
    static let bodyRegular: UIFont = .systemFont(ofSize: 17, weight: .regular)
    static let bodyEmphasized: UIFont = .systemFont(ofSize: 17, weight: .semibold)
    
    // MARK: Callout
    static let calloutEmphasized: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    
    // MARK: Footnote
    static let footnoteRegular: UIFont = .systemFont(ofSize: 13, weight: .regular)
    static let footnoteEmphasized: UIFont = .systemFont(ofSize: 13, weight: .semibold)
    
    // MARK: 커스텀 폰트 헬퍼
    // TODO: 이후 커스텀 폰트 추가시
    // Enum 로우벨류로 스트링타입으로 하나 추가하고 static func로 커스텀 함수 만들기.
    
    // MARK: Button Title
    static let buttonTitle: UIFont = .systemFont(ofSize: 17, weight: .medium)
}

// SwiftUI Extension

extension Font {
    // MARK: Large Title
    static let largeTitleEmphasized: Font = .system(size: 34, weight: .bold)
    
    // MARK: Title
    static let title1Emphasized: Font = .system(size: 28, weight: .bold)
    static let title2Emphasized: Font = .system(size: 22, weight: .bold)
    static let title3Emphasized: Font = .system(size: 20, weight: .semibold)
    
    // MARK: Headline / Subheadline
    static let headlineRegular: Font = .system(size: 17, weight: .semibold)
    static let subheadlineRegular: Font = .system(size: 15, weight: .regular)
    static let subheadlineEmphasized: Font = .system(size: 15, weight: .semibold)
    
    // MARK: Body
    static let bodyRegular: Font = .system(size: 17, weight: .regular)
    static let bodyEmphasized: Font = .system(size: 17, weight: .semibold)
    
    // MARK: Callout
    static let calloutEmphasized: Font = .system(size: 16, weight: .semibold)
    
    // MARK: Footnote
    static let footnoteRegular: Font = .system(size: 13, weight: .regular)
    static let footnoteEmphasized: Font = .system(size: 13, weight: .semibold)
    
    // MARK: Button Title
    static let buttonTitle: Font = .system(size: 17, weight: .medium)
}
