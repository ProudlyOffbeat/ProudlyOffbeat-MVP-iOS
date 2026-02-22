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
//
// UIFontMetrics.scaledFont(for:) 를 사용하면
// 설정 → 디스플레이 → 텍스트 크기 변경 시 자동으로 폰트 크기가 조절됩니다.

extension UIFont {

    // MARK: Large Title
    static let largeTitleEmphasized: UIFont = scaled(.largeTitle, size: 34, weight: .bold)

    // MARK: Title
    static let title1Emphasized: UIFont = scaled(.title1, size: 28, weight: .bold)
    static let title2Emphasized: UIFont = scaled(.title2, size: 22, weight: .bold)
    static let title3Emphasized: UIFont = scaled(.title3, size: 20, weight: .semibold)

    // MARK: Headline / Subheadline
    static let headlineRegular: UIFont = scaled(.headline, size: 17, weight: .semibold)
    static let subheadlineRegular: UIFont = scaled(.subheadline, size: 15, weight: .regular)
    static let subheadlineEmphasized: UIFont = scaled(.subheadline, size: 15, weight: .semibold)

    // MARK: Body
    static let bodyRegular: UIFont = scaled(.body, size: 17, weight: .regular)
    static let bodyMedium: UIFont = scaled(.body, size: 17, weight: .medium)
    static let bodyEmphasized: UIFont = scaled(.body, size: 17, weight: .semibold)

    // MARK: Callout
    static let calloutEmphasized: UIFont = scaled(.callout, size: 16, weight: .semibold)

    // MARK: Footnote
    static let footnoteRegular: UIFont = scaled(.footnote, size: 13, weight: .regular)
    static let footnoteEmphasized: UIFont = scaled(.footnote, size: 13, weight: .semibold)

    // MARK: Button Title
    static let buttonTitle: UIFont = scaled(.body, size: 17, weight: .medium)

    // MARK: - Helper

    private static func scaled(_ textStyle: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}

// SwiftUI Extension
//
// SwiftUI의 .body, .title2 등 빌트인 TextStyle은 Dynamic Type을 자동 지원합니다.
// 여기서는 디자인 시스템의 weight를 유지하면서 TextStyle 기반으로 스케일링합니다.

extension Font {

    // MARK: Large Title
    static let largeTitleEmphasized: Font = .system(.largeTitle, weight: .bold)

    // MARK: Title
    static let title1Emphasized: Font = .system(.title, weight: .bold)
    static let title2Emphasized: Font = .system(.title2, weight: .bold)
    static let title3Emphasized: Font = .system(.title3, weight: .semibold)

    // MARK: Headline / Subheadline
    static let headlineRegular: Font = .system(.headline, weight: .semibold)
    static let subheadlineRegular: Font = .system(.subheadline, weight: .regular)
    static let subheadlineEmphasized: Font = .system(.subheadline, weight: .semibold)

    // MARK: Body
    static let bodyRegular: Font = .system(.body, weight: .regular)
    static let bodyMedium: Font = .system(.body, weight: .medium)
    static let bodyEmphasized: Font = .system(.body, weight: .semibold)

    // MARK: Callout
    static let calloutEmphasized: Font = .system(.callout, weight: .semibold)

    // MARK: Footnote
    static let footnoteRegular: Font = .system(.footnote, weight: .regular)
    static let footnoteEmphasized: Font = .system(.footnote, weight: .semibold)

    // MARK: Button Title
    static let buttonTitle: Font = .system(.body, weight: .medium)
}
