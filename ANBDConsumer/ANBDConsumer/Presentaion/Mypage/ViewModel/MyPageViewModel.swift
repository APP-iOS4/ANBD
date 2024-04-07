//
//  MypageViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI

final class MyPageViewModel: ObservableObject {
    @Published var userProfileImage: UIImage = UIImage(named: "DefaultUserProfileImage.001.png")!
    @Published var userNickname: String = "김마루"
    // 임시로 String 값으로 처리
    @Published var userPreferredTradingArea: String = "경기"
}
