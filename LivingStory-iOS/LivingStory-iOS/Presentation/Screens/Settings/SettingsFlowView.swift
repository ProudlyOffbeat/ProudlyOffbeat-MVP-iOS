//
//  SettingsFlowView.swift
//  LivingStory-iOS
//
//  설정 플로우 — UIKit 코디네이터 위에서 "이 화면들만" SwiftUI NavigationStack이 네비바를 소유.
//  (UIKit UIHostingController 호스팅에선 native large 타이틀의 스크롤↔바 연동이 깨져
//   진입 시 inline → 당겨야 large로 "뵹" 튀는 글리치가 생김. SwiftUI가 바를 소유하면 해결.)
//  추후 앱 전체를 SwiftUI 라우터로 전환하면 이 격리는 통합/제거 예정.
//

import SwiftUI
import UIKit

/// 설정 하위 화면 경로
enum SettingsRoute: Hashable {
    case childAge
    case notification
    case home
}

struct SettingsFlowView: View {
    let coordinator: AppCoordinator
    @State private var path: [SettingsRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            SettingsView(coordinator: coordinator, path: $path)
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .childAge:     ChildAgeSettingView()
                    case .notification: NotificationTimeSettingView()
                    case .home:         HomeSelectionView()
                    }
                }
        }
        .preferredColorScheme(.dark)
    }
}

/// 화면 표시 동안만 UIKit 네비바를 숨김(아래 SwiftUI NavigationStack이 바를 소유) → 이탈 시 복원.
/// 복원이 없으면 설정에서 빠져나간 뒤 StatisticsView 등 UIKit 네비바를 쓰는 화면의 바가 사라짐.
final class NavBarHiddenHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
