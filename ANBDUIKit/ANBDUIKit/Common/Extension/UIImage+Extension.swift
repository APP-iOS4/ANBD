//
//  UIImage+Extension.swift
//  ANBDUIKit
//
//  Created by 최주리 on 6/17/24.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
