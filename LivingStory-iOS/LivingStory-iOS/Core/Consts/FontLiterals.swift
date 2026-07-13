//
//  FontLiterals.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 앱 타이포그래피 시스템 — Atomic (Pretendard 기반)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  ✅ Pretendard 정적 otf 5종(Light/Regular/Medium/SemiBold/Bold) 번들 + Info.plist 등록 완료.
//
//  ℹ️ Letter Spacing / Line Height는 UIFont·Font에 담을 수 없어 각 토큰 주석에만 표기했습니다.
//     적용이 필요한 곳에서 UIKit은 NSAttributedString(kern/paragraphStyle),
//     SwiftUI는 `.tracking()` / `.lineSpacing()` 으로 보완하세요.
//
//  🧑‍💻 UIKit:  label.font = .title1SemiBold
//  📱 SwiftUI: Text("..").font(.title1SemiBold)
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit
import SwiftUI

// MARK: - Pretendard Name Mapping

private func pretendardName(_ weight: UIFont.Weight) -> String {
    switch weight {
    case .light:    return "Pretendard-Light"
    case .medium:   return "Pretendard-Medium"
    case .semibold: return "Pretendard-SemiBold"
    case .bold:     return "Pretendard-Bold"
    default:        return "Pretendard-Regular"
    }
}

// MARK: - UIKit (UIFont)

extension UIFont {

    // ───── Large Title ─────
    /// 56 Medium · LS -4%
    static let largeTitleMedium = pretendard(.largeTitle, size: 56, weight: .medium)

    // ───── Title ─────
    /// 32 SemiBold
    static let title1SemiBold = pretendard(.title1, size: 32, weight: .semibold)
    /// 30 Medium
    static let title2Medium = pretendard(.title2, size: 30, weight: .medium)
    /// 26 SemiBold · LS +1%
    static let title3SemiBold = pretendard(.title3, size: 26, weight: .semibold)
    /// 26 Regular
    static let title3Regular = pretendard(.title3, size: 26, weight: .regular)
    /// 26 Emphasized (= SemiBold)
    static let title3Emphasized = pretendard(.title3, size: 26, weight: .semibold)

    // ───── Headline ─────
    /// 24 Medium
    static let headlineMedium = pretendard(.title3, size: 24, weight: .medium)
    static let headlineRegular = pretendard(.headline, size: 17, weight: .regular)   // 표준 Headline 17
    /// 24 Medium · LH 140% · LS +2%
    static let headlineParagraph = pretendard(.title3, size: 24, weight: .medium)

    // ───── Body 1 ─────
    /// 20 SemiBold · LS -2%
    static let body1SemiBold = pretendard(.body, size: 20, weight: .semibold)
    /// 20 Medium
    static let body1Medium = pretendard(.body, size: 20, weight: .medium)
    /// 20 Regular
    static let body1Regular = pretendard(.body, size: 20, weight: .regular)

    // ───── Body 2 ─────
    /// 18 Bold
    static let body2Bold = pretendard(.body, size: 18, weight: .bold)
    /// 18 SemiBold
    static let body2SemiBold = pretendard(.body, size: 18, weight: .semibold)
    /// 18 Medium
    static let body2Medium = pretendard(.body, size: 18, weight: .medium)
    /// 18 Regular
    static let body2Regular = pretendard(.body, size: 18, weight: .regular)
    /// 18 Light · LS +1%
    static let body2Light = pretendard(.body, size: 18, weight: .light)

    // ───── Callout ─────
    /// 16 SemiBold · LS +2%
    static let calloutSemiBold = pretendard(.callout, size: 16, weight: .semibold)
    /// 16 Medium
    static let calloutMedium = pretendard(.callout, size: 16, weight: .medium)
    /// 16 Regular · LH 140%
    static let calloutParagraph = pretendard(.callout, size: 16, weight: .regular)
    /// 16 Regular
    static let calloutRegular = pretendard(.callout, size: 16, weight: .regular)
    /// 16 Light
    static let calloutLight = pretendard(.callout, size: 16, weight: .light)

    // ───── Label ─────
    /// 14 Medium · LS +2%
    static let labelMediumLoose = pretendard(.subheadline, size: 14, weight: .medium)
    /// 14 Medium
    static let labelMedium = pretendard(.subheadline, size: 14, weight: .medium)
    /// 14 Regular
    static let labelRegular = pretendard(.subheadline, size: 14, weight: .regular)
    /// 14 Regular · LH 135% · LS +2%
    static let labelParagraph = pretendard(.subheadline, size: 14, weight: .regular)

    // ───── Footnote ─────
    /// 13 Regular · LS -0.6% · LH 18px
    static let footnoteRegular = pretendard(.footnote, size: 13, weight: .regular)

    // ───── App Custom (Figma 타입스케일 외 · 특정 화면 전용) ─────
    /// 66 SemiBold — 나이 설정 값
    static let display1SemiBold = pretendard(.largeTitle, size: 66, weight: .semibold)
    /// 28 SemiBold — 나이 단위(세)
    static let display2SemiBold = pretendard(.title1, size: 28, weight: .semibold)
    /// 22 Regular — 나이 접두(만)
    static let display3Regular = pretendard(.title1, size: 22, weight: .regular)
    /// 28 Bold — 통계 타이틀 (Figma Title1/Emphasized)
    static let title1Emphasized = pretendard(.title1, size: 28, weight: .bold)
    /// 13 SemiBold — 배지 (Figma Footnote/Emphasized)
    static let footnoteEmphasized = pretendard(.footnote, size: 13, weight: .semibold)
    /// 17 Medium — 글래스 버튼
    static let buttonMedium = pretendard(.body, size: 17, weight: .medium)
    /// 15 Medium — 글래스 필
    static let buttonSmallMedium = pretendard(.subheadline, size: 15, weight: .medium)

    // MARK: Helper
    private static func pretendard(_ textStyle: UIFont.TextStyle, size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont(name: pretendardName(weight), size: size)!
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}

// MARK: - SwiftUI (Font)

extension Font {

    // ───── Large Title ─────
    static let largeTitleMedium = pretendard(56, .medium, .largeTitle)

    // ───── Title ─────
    static let title1SemiBold = pretendard(32, .semibold, .title)
    static let title2Medium = pretendard(30, .medium, .title2)
    static let title3SemiBold = pretendard(26, .semibold, .title3)

    // ───── Headline ─────
    static let headlineMedium = pretendard(24, .medium, .title3)
    static let headlineParagraph = pretendard(24, .medium, .title3)

    // ───── Body 1 ─────
    static let body1SemiBold = pretendard(20, .semibold, .body)
    static let body1Medium = pretendard(20, .medium, .body)
    static let body1Regular = pretendard(20, .regular, .body)

    // ───── Body 2 ─────
    static let body2Bold = pretendard(18, .bold, .body)
    static let body2SemiBold = pretendard(18, .semibold, .body)
    static let body2Medium = pretendard(18, .medium, .body)
    static let body2Regular = pretendard(18, .regular, .body)
    static let body2Light = pretendard(18, .light, .body)

    // ───── Callout ─────
    static let calloutSemiBold = pretendard(16, .semibold, .callout)
    static let calloutMedium = pretendard(16, .medium, .callout)
    static let calloutParagraph = pretendard(16, .regular, .callout)
    static let calloutRegular = pretendard(16, .regular, .callout)
    static let calloutLight = pretendard(16, .light, .callout)

    // ───── Label ─────
    static let labelMediumLoose = pretendard(14, .medium, .subheadline)
    static let labelMedium = pretendard(14, .medium, .subheadline)
    static let labelRegular = pretendard(14, .regular, .subheadline)
    static let labelParagraph = pretendard(14, .regular, .subheadline)

    // ───── Footnote ─────
    static let footnoteRegular = pretendard(13, .regular, .footnote)

    // ───── App Custom (Figma 타입스케일 외 · 특정 화면 전용) ─────
    /// 66 SemiBold — 나이 설정 값
    static let display1SemiBold = pretendard(66, .semibold, .largeTitle)
    /// 28 SemiBold — 나이 단위(세)
    static let display2SemiBold = pretendard(28, .semibold, .title)
    /// 22 Regular — 나이 접두(만)
    static let display3Regular = pretendard(22, .regular, .title)
    /// 28 Bold — 통계 타이틀 (Figma Title1/Emphasized)
    static let title1Emphasized = pretendard(28, .bold, .title)
    /// 13 SemiBold — 배지 (Figma Footnote/Emphasized)
    static let footnoteEmphasized = pretendard(13, .semibold, .footnote)
    /// 17 Medium — 글래스 버튼
    static let buttonMedium = pretendard(17, .medium, .body)
    /// 15 Medium — 글래스 필
    static let buttonSmallMedium = pretendard(15, .medium, .subheadline)

    // MARK: Helper
    private static func pretendard(_ size: CGFloat, _ weight: Font.Weight, _ relativeTo: Font.TextStyle) -> Font {
        .custom(pretendardNameFor(weight), size: size, relativeTo: relativeTo)
    }
}

private func pretendardNameFor(_ weight: Font.Weight) -> String {
    switch weight {
    case .light:    return "Pretendard-Light"
    case .medium:   return "Pretendard-Medium"
    case .semibold: return "Pretendard-SemiBold"
    case .bold:     return "Pretendard-Bold"
    default:        return "Pretendard-Regular"
    }
}
