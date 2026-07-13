//
//  ScreenBackground+SwiftUI.swift
//  LivingStory-iOS
//
//  UIKit BaseViewController의 ScreenBackgroundColor를 SwiftUI에서도 동일하게 사용.
//  사용: someView.screenBackground(.secondary)
//

import SwiftUI

extension ScreenBackgroundColor {
    var swiftUIColor: Color { Color(uiColor: color) }
}

extension View {
    /// 화면 배경을 가장자리까지 채움 (기본 secondary)
    func screenBackground(_ style: ScreenBackgroundColor = .secondary) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(style.swiftUIColor.ignoresSafeArea())
    }
}
