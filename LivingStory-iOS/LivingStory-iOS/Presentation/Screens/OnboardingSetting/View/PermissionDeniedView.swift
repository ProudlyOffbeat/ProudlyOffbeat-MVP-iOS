//
//  PermissionDeniedView.swift
//  LivingStory-iOS
//
//  HomeKit 권한 거부 시 "홈 앱 권한 허용 필요" 화면 (#27).
//  문자열은 기존 StringLiterals.Home.permission* 재사용.
//

import SwiftUI

struct PermissionDeniedView: View {
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "house.badge.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            Text(StringLiterals.Home.permissionTitle)
                .font(.body1SemiBold)
                .foregroundStyle(.white)

            Text(StringLiterals.Home.permissionSubtitle)
                .font(.calloutRegular)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onOpenSettings) {
                Text(StringLiterals.Home.permissionButton)
                    .font(.body2SemiBold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background {
                        Capsule().foregroundStyle(.black).glassEffect()   // 검정 글래스
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .screenBackground(.secondary)
    }
}
