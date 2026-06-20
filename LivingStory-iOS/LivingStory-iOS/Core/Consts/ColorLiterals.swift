//
//  ColorLiterals.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  🎨 앱 컬러 시스템 — HEX 헬퍼 & Atomic Gradation 토큰
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  단색(Yellow/Blue/Green)은 Colors.xcassets colorset으로 관리합니다.
//  그라데이션은 colorset에 담을 수 없어 이 파일에서 토큰으로 정의합니다.
//
//  🧑‍💻 UIKit 사용법:
//  ```swift
//  let layer = AppGradient.g30.makeLayer()
//  layer.frame = view.bounds
//  view.layer.insertSublayer(layer, at: 0)
//  ```
//
//  📱 SwiftUI 사용법:
//  ```swift
//  Rectangle().fill(AppGradient.g30.linear)
//  // 또는
//  someView.background(AppGradient.g30.linear)
//  ```
//
//  HEX 단색:
//  ```swift
//  Color(hex: 0xFBC928)            // SwiftUI
//  UIColor(hex: 0x314760)          // UIKit
//  Color(hex: 0xFFF761, alpha: 0.5)
//  ```
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit
import SwiftUI

// MARK: - HEX Initializers

extension UIColor {
    /// `UIColor(hex: 0x314760)` — 0xRRGGBB
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

extension Color {
    /// `Color(hex: 0xFBC928)` — 0xRRGGBB
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// MARK: - Gradient Token

/// 하나의 그라데이션 토큰. SwiftUI(`linear`)와 UIKit(`makeLayer()`)에서 동일한 stop으로 사용.
struct GradientToken {

    /// (hex: 0xRRGGBB, location: 0.0~1.0, alpha: 0.0~1.0)
    struct Stop {
        let hex: UInt
        let location: Double
        let alpha: Double
    }

    let stops: [Stop]

    init(_ stops: [(hex: UInt, location: Double, alpha: Double)]) {
        self.stops = stops.map { Stop(hex: $0.hex, location: $0.location, alpha: $0.alpha) }
    }

    /// SwiftUI — 가로 방향(좌→우)
    var linear: LinearGradient {
        LinearGradient(
            stops: stops.map {
                Gradient.Stop(color: Color(hex: $0.hex, alpha: $0.alpha), location: $0.location)
            },
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// UIKit — 가로 방향(좌→우) CAGradientLayer 생성. frame은 호출부에서 지정.
    func makeLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = stops.map { UIColor(hex: $0.hex, alpha: $0.alpha).cgColor }
        layer.locations = stops.map { NSNumber(value: $0.location) }
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        return layer
    }
}

// MARK: - Atomic Gradation Palette

/// Atomic 디자인 시스템 그라데이션 토큰 (가로 좌→우).
/// 50·100은 시안상 약간 대각선이라, 필요 시 해당 토큰의 start/endPoint만 조정.
enum AppGradient {

    /// 10 — 0% #FFF761 → 100% #FFCC24 (전체 투명도 50%)
    static let g10 = GradientToken([
        (0xFFF761, 0.0, 0.5),
        (0xFFCC24, 1.0, 0.5),
    ])

    /// 20 — 0% #AADBFF → 100% #0093FF
    static let g20 = GradientToken([
        (0xAADBFF, 0.0, 1.0),
        (0x0093FF, 1.0, 1.0),
    ])

    /// 30 — 0% #BFEE68 → 100% #FFCB24
    static let g30 = GradientToken([
        (0xBFEE68, 0.0, 1.0),
        (0xFFCB24, 1.0, 1.0),
    ])

    /// 40 — 0% #92CFB1 → 35% #BFEE68 → 100% #FECB24
    static let g40 = GradientToken([
        (0x92CFB1, 0.0, 1.0),
        (0xBFEE68, 0.35, 1.0),
        (0xFECB24, 1.0, 1.0),
    ])

    /// 50 — 0% #BFEE68 → 100% #64B0FF
    static let g50 = GradientToken([
        (0xBFEE68, 0.0, 1.0),
        (0x64B0FF, 1.0, 1.0),
    ])

    /// 60 — 0% #64B1FF → 60% #BFEE68 → 100% #E4D940
    static let g60 = GradientToken([
        (0x64B1FF, 0.0, 1.0),
        (0xBFEE68, 0.60, 1.0),
        (0xE4D940, 1.0, 1.0),
    ])

    /// 100 — 16% #63B0FF → 42% #BFEE68 → 79% #FFCB24
    static let g100 = GradientToken([
        (0x63B0FF, 0.16, 1.0),
        (0xBFEE68, 0.42, 1.0),
        (0xFFCB24, 0.79, 1.0),
    ])
}
