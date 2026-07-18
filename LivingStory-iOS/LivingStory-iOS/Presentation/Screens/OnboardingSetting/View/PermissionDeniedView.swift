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
                .font(.system(size: 66))                 // 빈 상태(기기 없음)와 동일 크기
                .foregroundStyle(.white)                 // 흰색 아이콘 (빈 상태와 통일)
                .padding(.bottom, 8)

            Text(StringLiterals.Home.permissionTitle)
                .font(.body1SemiBold)
                .foregroundStyle(.white)

            Text(StringLiterals.Home.permissionSubtitle)
                .font(.calloutRegular)
                .foregroundStyle(Color(red: 0xEB/255, green: 0xEB/255, blue: 0xF5/255).opacity(0.6))  // 빈 상태와 동일 세컨더리 그레이
                .multilineTextAlignment(.center)

            // 앱 표준 리퀴드 글래스 CTA (clear — 검정이라 안 보이던 문제 해결)
            PrimaryButtonSwiftUI(title: StringLiterals.Home.permissionButton) {
                onOpenSettings()
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
        .screenBackground(.secondary)
    }
}
