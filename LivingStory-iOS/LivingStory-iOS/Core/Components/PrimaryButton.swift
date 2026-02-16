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
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor(named: "blue0")
        config.baseForegroundColor = .white
        config.background.cornerRadius = 12
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: 24, bottom: 16, trailing: 24
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .headlineRegular
            return outgoing
        }
        super.init(frame: .zero)
        self.configuration = config
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SwiftUI Version

struct PrimaryButtonSwiftUI: View {
    @Environment(\.colorScheme) var scheme
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Capsule()
                .frame(height: 52)
                .foregroundStyle(scheme == .dark ? .clear : .black)
                .glassEffect()
                .overlay {
                    Text(title)
                        .font(.buttonTitle)
                        .foregroundStyle(.white)
                }
        }
    }
}

struct WhiteButtonSwiftUI: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Capsule()
                .frame(height: 52)
                .foregroundStyle(.clear)
                .glassEffect()
                .overlay {
                    Text(title)
                        .font(.buttonTitle)
                        .foregroundStyle(.black)
                        .opacity(0.7)
                }
        }
    }
}

#Preview {
    WhiteButtonSwiftUI(title: "테스트 버튼") {}
}
