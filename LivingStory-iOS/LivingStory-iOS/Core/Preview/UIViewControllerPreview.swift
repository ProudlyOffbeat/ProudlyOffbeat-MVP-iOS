//
//  UIViewControllerPreview.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 UIKit 라이브 프리뷰
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  왜 필요한가?
//  - SwiftUI는 Canvas에서 실시간 프리뷰 가능
//  - UIKit은 원래 안 됨 → 이 wrapper로 가능하게!
//  - 빌드 없이 UI 확인 가능 = 개발 속도 UP
//
//  사용법:
//  ```swift
//  // ViewController 파일 맨 아래에 추가
//  #Preview {
//      HomeViewController()
//  }
//  ```
//
//  또는 (iOS 16 이하 지원 필요시):
//  ```swift
//  struct HomeViewController_Previews: PreviewProvider {
//      static var previews: some View {
//          UIViewControllerPreview {
//              HomeViewController()
//          }
//      }
//  }
//  ```
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI
import UIKit

// MARK: - UIViewController Preview Wrapper

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {

    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

// MARK: - UIView Preview Wrapper

struct UIViewPreview<View: UIView>: UIViewRepresentable {

    let view: View

    init(_ builder: @escaping () -> View) {
        view = builder()
    }

    func makeUIView(context: Context) -> View {
        view
    }

    func updateUIView(_ uiView: View, context: Context) {}
}
