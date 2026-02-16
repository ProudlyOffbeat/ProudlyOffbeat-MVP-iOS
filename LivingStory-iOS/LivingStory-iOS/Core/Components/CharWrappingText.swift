import UIKit
import SwiftUI

struct CharWrappingText: UIViewRepresentable {
    let text: String
    let font: UIFont
    var color: UIColor = .label

    func makeUIView(context: Context) -> WrappingLabel {
        let label = WrappingLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }

    func updateUIView(_ uiView: WrappingLabel, context: Context) {
        uiView.text = text
        uiView.font = font
        uiView.textColor = color
    }
}

final class WrappingLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = bounds.width
    }
}
