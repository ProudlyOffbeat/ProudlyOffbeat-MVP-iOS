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
                // Labels/Tertiary (iOS 시스템색)
                .foregroundStyle(Color(.tertiaryLabel))

            VStack(alignment: .leading, spacing: 12) {
                Text(headline)
                    .font(.title3SemiBold)
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.body2Light)
                    // Labels/Secondary (iOS 시스템색)
                    .foregroundStyle(Color(.secondaryLabel))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
