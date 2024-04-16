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
    static let mockUser = User(id: "abcd1234",
                               nickname: "김마루",
                               profileImage: "DefaultUserProfileImage",
                               email: "sjybext@naver.com",
                               favoriteLocation: .jeju,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published var userProfileImage: UIImage = UIImage(named: "DefaultUserProfileImage.001.png")!
    
    @Published var user = User(id: "abcd1234",
                               nickname: "김마루",
                               profileImage: "DefaultUserProfileImage",
                               email: "sjybext@naver.com",
                               favoriteLocation: .jeju,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published private(set) var userArticles: [Article] = []
    @Published private(set) var userTrades: [Trade] = []
    
    @Published private(set) var userLikedArticles: [Article] = []
    @Published private(set) var userHeartedTrades: [Trade] = []
    
    let mockArticleData: [Article] = [
    ]
    
    let mockTradeData: [Trade] = [
    ]
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    @Published var myPageNaviPath = NavigationPath()
    
    func validateEditingComplete() -> Bool {
        if (editedUserNickname.isEmpty || editedUserNickname == self.user.nickname) && (tempUserFavoriteLocation != self.user.favoriteLocation) {
            return true
        } else {
            return false
        }
    }
}

extension MyPageViewModel {
    enum MyPageNaviPaths {
        case userLikedArticleList
        case userHeartedTradeList
        case accountManagement
    }
}
