//
//  PrimaryButton.swift
//  LivingStory-iOS
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  📚 재사용 가능한 버튼 컴포넌트
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  사용법 (UIKit):
//  ```swift
//  let button = PrimaryButton(title: "시작하기")
//  button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
//  view.addSubview(button)
//  ```
//
//  사용법 (SwiftUI):
//  ```swift
//  PrimaryButtonSwiftUI(title: "시작하기") {
//      // 액션
//  }
//  ```
//
//  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import UIKit
import SwiftUI

// MARK: - UIKit Version

final class PrimaryButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupStyle() {
        backgroundColor = UIColor(named: "blue0")
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .headlineRegular
        layer.cornerRadius = 12
        contentEdgeInsets = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
    }
}

// MARK: - SwiftUI Version

struct PrimaryButtonSwiftUI: View {

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Capsule()
                .frame(height: 52)
                  .padding(.horizontal, 20)
                .foregroundStyle(.black)
                .glassEffect()
                .overlay {
                    Text(title)
                        .font(.buttonTitle)
                        .foregroundStyle(.white)
                }
        }
    }
}
