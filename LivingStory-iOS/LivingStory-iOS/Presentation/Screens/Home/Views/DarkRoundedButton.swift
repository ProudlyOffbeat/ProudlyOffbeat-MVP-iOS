//
//  DarkRoundedButton.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class DarkRoundedButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)

        // 앱 표준 리퀴드 글래스와 통일 (clear — "홈으로" 버튼과 동일)
        var config = UIButton.Configuration.glass()
        config.title = title
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 15, leading: 40.5, bottom: 15, trailing: 40.5
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.body2SemiBold
            return outgoing
        }
        configuration = config
        titleLabel?.adjustsFontForContentSizeCategory = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

