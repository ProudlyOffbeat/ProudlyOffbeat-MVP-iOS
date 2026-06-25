//
//  BaseViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 6/21/26.
//

import UIKit

enum ScreenBackgroundColor {
    case primary
    case secondary
    
    var color: UIColor {
        switch self {
            case .primary: return .systemBackground
            case .secondary: return .secondarySystemBackground
        }
    }
}

class BaseViewController: UIViewController {
    /// 화면마다 이거만 override (기본은 세컨더리)
    var backgroundStyle: ScreenBackgroundColor { .secondary }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = backgroundStyle.color
    }
}
