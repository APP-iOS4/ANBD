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
    private let articleUsecase: ArticleUsecase = DefaultArticleUsecase()
    private let tradeUsecase: TradeUsecase = DefaultTradeUsecase()
    
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
    
    // 최종적으로 여기 담기는거지!요
    @Published private(set) var accuaArticlesWrittenByUser: [Article] = []
    @Published private(set) var dasiArticlesWrittenByUser: [Article] = []
    @Published private(set) var nanuaTradesWrittenByUser: [Trade] = []
    @Published private(set) var baccuaTradesWrittenByUser: [Trade] = []
    
    @Published private(set) var userLikedArticles: [Article] = []
    @Published private(set) var userHeartedTrades: [Trade] = []
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    @Published var myPageNaviPath = NavigationPath()
    
    init() { }
    
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
    
    @MainActor
    func loadArticlesWrittenByUser(userID: String, limit: Int = 10) async {
        do {
            // 이거 왜 109번 처럼 Append로 넣어야 정상적인 작동을 하는지 궁금해요!
            // articlesWrittenByUser = try await articleUsecase.loadArticleList(writerID: userID, limit: limit)
            
            // 그걸 불러와서 뷰 모델의 articlesWrittenByUser의 여기에 담는거죠?
            // 혹시 잘 보고 있으면 >< 한번 쳐주셈
            try await articlesWrittenByUser.append(contentsOf: articleUsecase.loadArticleList(writerID: userID, limit: limit))
            
            // articlesWrittenByUser += try await articleUsecase.loadArticleList(writerID: userID, limit: limit)
        } catch {
            print("Error load articles written by user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func loadTradesWrittenByUser(userID: String, limit: Int = 10) async {
        do {
            try await tradesWrittenByUser.append(contentsOf: tradeUsecase.loadTradeList(writerID: userID, limit: limit))
        } catch {
            print("Error load Trades written by user: \(error.localizedDescription)")
        }
    }
    
    func clearANBDListWrittenByUser() {
        articlesWrittenByUser = []
        tradesWrittenByUser = []
    }
    
    func filterANBDListWrittenByUser() {
        
        // 그럼 담은 걸 아 다로 구분하기 위해 이 메서드에서 구분하고 최종적으로
        accuaArticlesWrittenByUser = articlesWrittenByUser.filter({ $0.category == .accua})
        dasiArticlesWrittenByUser = articlesWrittenByUser.filter({ $0.category == .dasi})
        
        nanuaTradesWrittenByUser = tradesWrittenByUser.filter({ $0.category == .nanua})
        baccuaTradesWrittenByUser = tradesWrittenByUser.filter({ $0.category == .baccua})
    }
    
//    func filterList(by category: ANBDCategory, user: User) -> [Any] {
//        switch category {
//        case .accua:
//            let filteredList = user.likeArticles.filter({ $0.category == category })
//            return
//        case .nanua:
//            <#code#>
//        case .baccua:
//            <#code#>
//        case .dasi:
//            <#code#>
//        }
//    }
    
    // MARK: - 유저 정보 수정
    func checkDuplicatedNickname() async -> Bool {
        let isDuplicate = await userUsecase.checkDuplicatedNickname(nickname: editedUserNickname)
        
        return isDuplicate
    }
    
    func checkNicknameLength(_ nickname: String) -> String {
        if nickname.count > 20 {
            return String(nickname.prefix(20))
        } else {
            return nickname
        }
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
            var updatedUser: User = UserStore.shared.user
            
            updatedUser.nickname = updatedNickname
            updatedUser.favoriteLocation = updatedLocation
            
            try await userUsecase.updateUserInfo(user: updatedUser)
            UserStore.shared.user = updatedUser
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
