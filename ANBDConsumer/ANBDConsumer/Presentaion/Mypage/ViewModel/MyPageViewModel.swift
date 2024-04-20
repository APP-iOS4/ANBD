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
                               nickname: "알수 없음",
                               profileImage: "DefaultUserProfileImage",
                               email: "anbd@anbd.com",
                               favoriteLocation: .seoul,
                               userLevel: .consumer,
                               isOlderThanFourteen: true,
                               isAgreeService: true,
                               isAgreeCollectInfo: true,
                               isAgreeMarketing: true,
                               likeArticles: [],
                               likeTrades: [])
    
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    
    private let userDefaultsClient = UserDefaultsClient.shared
    private let storageManager = StorageManager.shared
    
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
    
    @Published private(set) var articlesWrittenByUser: [Article] = []
    @Published private(set) var tradesWrittenByUser: [Trade] = []
    
    @Published private(set) var userLikedArticles: [Article] = []
    @Published private(set) var userHeartedTrades: [Trade] = []
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    @Published var myPageNaviPath = NavigationPath()
    
    init() {
        self.loadUserInfo()
    }
    
    func checkSignInedUser(userID: String) -> Bool {
        if userID == UserStore.shared.user.id {
            return true
        } else {
            return false
        }
    }
    
    func getUserInfo(userID: String) async -> User {
        do {
            let getUser = try await userUsecase.getUserInfo(userID: userID)
            
            return getUser
        } catch {
            print("\(error.localizedDescription)")
            
            return MyPageViewModel.mockUser
        }
    }
    
    func loadUserInfo() {
        if let user = userDefaultsClient.userInfo {
            self.user = user
        }
    }
    
    func loadUserProfileImage(containerID: String, imagePath: String) async -> Data {
        var userProfilImageData: Data = Data()
        
        do {
            userProfilImageData = try await storageManager.downloadImage(path: .profile,
                                                                         containerID: containerID,
                                                                         imagePath: imagePath)
        } catch {
            print("\(error.localizedDescription)")
            
            let defaultUserProfileImage = UIImage(named: "DefaultUserProfileImage")
            let defaultUserProfileImageData = defaultUserProfileImage?.pngData()
            
            userProfilImageData = defaultUserProfileImageData ?? Data()
        }
        
        return userProfilImageData
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
            userDefaultsClient.userInfo = updatedUser
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
        case report
    }
}
