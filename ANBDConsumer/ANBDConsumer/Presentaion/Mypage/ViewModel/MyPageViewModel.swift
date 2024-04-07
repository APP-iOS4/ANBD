//
//  MypageViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

final class MyPageViewModel: ObservableObject {
    @Published var userProfileImage: UIImage = UIImage(named: "DefaultUserProfileImage.001.png")!
    
    @Published var user = User(id: "abcd1234",
                               nickname: "김마루",
                               profileImage: "DefaultUserProfileImage.001.png",
                               email: "sjybext@naver.com",
                               favoriteLocation: .jeju,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published var editedUserNickname = ""
    @Published var editedUserFavoriteLocation: Location = .seoul
    
    func checkVaildEditingComplete() -> Bool {
        if editedUserNickname.isEmpty || editedUserNickname == self.user.nickname {
            return true
        } else {
            return false
        }
    }
}
