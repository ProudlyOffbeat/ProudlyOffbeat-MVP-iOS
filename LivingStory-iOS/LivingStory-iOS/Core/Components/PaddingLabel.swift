//
//  PaddingLabel.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class PaddingLabel: UILabel {

    private var padding: UIEdgeInsets
    
    init(padding: UIEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)) {
        self.padding = padding
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.bottom + padding.top
            )
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
