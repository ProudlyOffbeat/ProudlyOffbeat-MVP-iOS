//
//  DynamicLabel.swift
//  LivingStory-iOS
//
//  시스템 텍스트 크기 변경 시 자동으로 폰트가 스케일링되는 UILabel 서브클래스.
//  UIKit의 UILabel은 adjustsFontForContentSizeCategory를 수동으로 켜야
//  Dynamic Type이 런타임에 반영되므로, 이를 기본 활성화한다.
//

import UIKit

class DynamicLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsFontForContentSizeCategory = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
