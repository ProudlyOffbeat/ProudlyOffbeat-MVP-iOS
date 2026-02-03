//
//  KeyboardAdaptive.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 키보드 어댑티브
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  왜 필요한가?
//  - 키보드가 올라오면 TextField가 가려짐
//  - 키보드 높이만큼 화면을 올려줘야 함
//  - UIKit과 SwiftUI 모두 지원
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  📱 SwiftUI 사용법:
//  ```swift
//  struct MyView: View {
//      @StateObject private var keyboard = KeyboardObserver()
//
//      var body: some View {
//          VStack {
//              TextField("입력", text: $text)
//          }
//          .padding(.bottom, keyboard.height)
//          .animation(.easeOut(duration: 0.25), value: keyboard.height)
//      }
//  }
//  ```
//
//  🧑‍💻 UIKit 사용법:
//  ```swift
//  class MyViewController: UIViewController {
//      private var keyboardHandler: KeyboardHandler?
//      private var bottomConstraint: NSLayoutConstraint!
//
//      override func viewDidLoad() {
//          super.viewDidLoad()
//          keyboardHandler = KeyboardHandler { [weak self] height in
//              self?.bottomConstraint.constant = -height
//              UIView.animate(withDuration: 0.25) {
//                  self?.view.layoutIfNeeded()
//              }
//          }
//      }
//  }
//  ```
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import SwiftUI
import Combine
import UIKit

// MARK: - SwiftUI용 키보드 Observer

final class KeyboardObserver: ObservableObject {

    @Published var height: CGFloat = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap { notification -> CGFloat? in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return frame.height
            }
            .assign(to: &$height)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .assign(to: &$height)
    }
}

// MARK: - UIKit용 키보드 Handler

final class KeyboardHandler {

    private var onHeightChange: ((CGFloat) -> Void)?

    init(onHeightChange: @escaping (CGFloat) -> Void) {
        self.onHeightChange = onHeightChange

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        onHeightChange?(frame.height)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        onHeightChange?(0)
    }
}

// MARK: - SwiftUI ViewModifier

struct KeyboardAdaptive: ViewModifier {

    @StateObject private var keyboard = KeyboardObserver()

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboard.height)
            .animation(.easeOut(duration: 0.25), value: keyboard.height)
    }
}

extension View {
    /// 키보드가 올라오면 자동으로 패딩 추가
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptive())
    }
}
