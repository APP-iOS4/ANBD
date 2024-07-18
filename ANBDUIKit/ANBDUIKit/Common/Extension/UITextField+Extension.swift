//
//  UITextField+Extension.swift
//  ANBDUIKit
//
//  Created by 최주리 on 7/18/24.
//

import UIKit

extension UITextField {
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = ViewMode.always
    }
}
