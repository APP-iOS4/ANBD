//
//  ANBDFont.swift
//  ANBD_Consumer
//
//  Created by 유지호 on 3/21/24.
//

import SwiftUI

enum ANBDFont {
    // MARK: Heading
    static let Heading1 = Font.custom("Pretendard-Bold", size: 48)
    static let Heading2 = Font.custom("Pretendard-Medium", size: 36)
    static let Heading3 = Font.custom("Pretendard-Medium", size: 24)
    
    // MARK: SubTitle
    static let SubTitle1 = Font.custom("Pretendard-SemiBold", size: 18)
    static let SubTitle2 = Font.custom("Pretendard-SemiBold", size: 16)
    static let SubTitle3 = Font.custom("Pretendard-SemiBold", size: 14)
    
    // MARK: Caption
    static let Caption1 = Font.custom("Pretendard-Regular", size: 12)
    static let Caption2 = Font.custom("Pretendard-Regular", size: 10)
    static let Caption3 = Font.custom("Pretendard-Regular", size: 14)
    
    // MARK: Body
    static let body1 = Font.custom("Pretendard-Regular", size: 16)
    static let body2 = Font.custom("Pretendard-Regular", size: 14)
    
    /// Pretendard-Bold 폰트
    ///
    /// 원하는 사이즈를 입력해서 쓰면 됩니다.
    static func pretendardBold(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Bold", size: size)
    }

    /// Pretendard-SemiBold 폰트
    ///
    /// 원하는 사이즈를 입력해서 쓰면 됩니다.
    static func pretendardSemiBold(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-SemiBold", size: size)
    }
    
    /// Pretendard-Medium 폰트
    ///
    /// 원하는 사이즈를 입력해서 쓰면 됩니다.
    static func pretendardMedium(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Medium", size: size)
    }
    
    /// Pretendard-Regular 폰트
    ///
    /// 원하는 사이즈를 입력해서 쓰면 됩니다.
    static func pretendardRegular(_ size: CGFloat) -> Font {
        return Font.custom("Pretendard-Regular", size: size)
    }
}
