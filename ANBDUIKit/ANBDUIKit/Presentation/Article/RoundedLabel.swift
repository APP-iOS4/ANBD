//
//  RoundedLabel.swift
//  PParking
//
//  Created by 유지호 on 5/16/24.
//

import UIKit

class RoundedLabel: UILabel {

    var padding: UIEdgeInsets

    
    init(
        padding: UIEdgeInsets = .init(top: 4.0, left: 6.0, bottom: 4.0, right: 6.0),
        cornerRadius: CGFloat = 8
    ) {
        self.padding = padding
        super.init(frame: .zero)
        
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right

        return contentSize
    }

}
