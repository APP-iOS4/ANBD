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
    
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    
    @Published var userProfileImage: UIImage = UIImage(named: "DefaultUserProfileImage.001.png")!
    
    @Published var user = User(id: "",
                               nickname: "",
                               profileImage: "",
                               email: "",
                               favoriteLocation: .seoul,
                               userLevel: .consumer,
                               isOlderThanFourteen: false,
                               isAgreeService: false,
                               isAgreeCollectInfo: false,
                               isAgreeMarketing: false,
                               likeArticles: [],
                               likeTrades: [])
    
    @Published private(set) var userArticles: [Article] = []
    @Published private(set) var userTrades: [Trade] = []
    
    @Published private(set) var userLikedArticles: [Article] = []
    @Published private(set) var userHeartedTrades: [Trade] = []
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    @Published var myPageNaviPath = NavigationPath()
    
    let mockArticleData: [Article] = []
    let mockTradeData: [Trade] = []
    
    func loadUserInfo() {
        if let user = UserDefaultsClient.shared.userInfo {
            self.user = user
        }
    }
    
    // MARK: - 유저 정보 수정
    func checkDuplicatedNickname() async -> Bool {
        let isDuplicate = await userUsecase.checkDuplicatedNickname(nickname: editedUserNickname)
        
        return isDuplicate
    }
    
    func validateUpdatingComplete() -> Bool {
        if (editedUserNickname.isEmpty || editedUserNickname == self.user.nickname) && (tempUserFavoriteLocation != self.user.favoriteLocation) {
            return true
        } else {
            return false
        }
    }
    
    func updateUserInfo(updatedNickname: String, updatedLocation: Location) async {
        do {
            var updatedUser: User = user
            
            updatedUser.nickname = updatedNickname
            updatedUser.favoriteLocation = updatedLocation
            
            try await userUsecase.updateUserInfo(user: updatedUser)
            UserDefaultsClient.shared.userInfo = updatedUser
        } catch {
            print("\(error.localizedDescription)")
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
