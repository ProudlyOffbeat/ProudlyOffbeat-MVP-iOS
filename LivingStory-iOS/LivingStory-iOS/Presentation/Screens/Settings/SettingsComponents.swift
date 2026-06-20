//
//  SettingsComponents.swift
//  LivingStory-iOS
//
//  설정 하위 화면 공용 컴포넌트 (헤더 / 인트로)
//

import SwiftUI

/// 아이콘 + 헤드라인 + 서브타이틀 (좌측 정렬)
struct SettingIntro: View {
    let systemImage: String
    let headline: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            Image(systemName: systemImage)
                .font(.system(size: 28))
                .foregroundStyle(Color(white: 0.92).opacity(0.3))

            VStack(alignment: .leading, spacing: 12) {
                Text(headline)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color(white: 0.92).opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
