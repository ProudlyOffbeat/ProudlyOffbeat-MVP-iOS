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

        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor(named: "gray0")
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        config.background.cornerRadius = 24
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 15, leading: 40.5, bottom: 15, trailing: 40.5
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.bodyEmphasized
            return outgoing
        }
        configuration = config
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#Preview {
    let vc = UIViewController()
    vc.view.backgroundColor = .white
    let button = DarkRoundedButton(title: "설정으로 이동")
    button.translatesAutoresizingMaskIntoConstraints = false
    vc.view.addSubview(button)
    NSLayoutConstraint.activate([
        button.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
        button.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
    ])
    return vc
}
