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
                               likeTrades: [],
                               accuaCount: 0,
                               nanuaCount: 0,
                               baccuaCount: 0,
                               dasiCount: 0)
    
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
                               likeTrades: [],
                               accuaCount: 0,
                               nanuaCount: 0,
                               baccuaCount: 0,
                               dasiCount: 0)
    
    @Published private(set) var accuaArticlesWrittenByUser: [Article] = []
    @Published private(set) var dasiArticlesWrittenByUser: [Article] = []
    @Published private(set) var nanuaTradesWrittenByUser: [Trade] = []
    @Published private(set) var baccuaTradesWrittenByUser: [Trade] = []
    
    @Published private(set) var userLikedArticles: [Article] = []
    @Published private(set) var userHeartedTrades: [Trade] = []
    
    /*
     // 좋아요, 찜 기능 완료 후 테스트
     @Published private(set) var userLikedAccuaArticles: [Article] = []
     @Published private(set) var userLikedDasiArticles: [Article] = []
     @Published private(set) var userHeartedNanuaTrades: [Trade] = []
     @Published private(set) var userHeartedBaccuaTrades: [Trade] = []
     */
    
    @Published var editedUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    @Published var otherUserNickname = ""
    
    @Published var myPageNaviPath = NavigationPath()
    
    init() { }
    
    // MARK: - 유저 관련 정보 불러오기
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
    
    func loadArticleList(of category: ANBDCategory, by userID: String, limit: Int = 10) async -> [Article] {
        do {
            let list = try await articleUsecase.refreshWriterIDArticleList(writerID: userID, category: category, limit: limit)
            
            return list
        } catch {
            print("Error load to list of \(category): \(error.localizedDescription)")
            
            return []
        }
    }
    
    func loadTradeList(of category: ANBDCategory, by userID: String, limit: Int = 10) async -> [Trade] {
        do {
            let list = try await tradeUsecase.refreshWriterIDTradeList(writerID: userID, category: category, limit: limit)
            
            return list
        } catch {
            print("Error load to list of \(category): \(error.localizedDescription)")
            
            return []
        }
    }
    
    @MainActor
    func loadAllUserActivityList(by userID: String) async {
        accuaArticlesWrittenByUser = await loadArticleList(of: .accua, by: userID)
        dasiArticlesWrittenByUser = await loadArticleList(of: .dasi, by: userID)
        
        nanuaTradesWrittenByUser = await loadTradeList(of: .nanua, by: userID)
        baccuaTradesWrittenByUser = await loadTradeList(of: .baccua, by: userID)
    }
    
    func loadUserLikedArticles(user: User) async {
        for articleID in user.likeArticles {
            do {
                let article = try await articleUsecase.loadArticle(articleID: articleID)
                userLikedArticles.append(article)
            } catch {
                print("Error load to article that the user likes: \(error.localizedDescription)")
            }
        }
    }
    
    func loadUserHeartedTrades(user: User) async {
        for tradeID in user.likeTrades {
            do {
                let trade = try await tradeUsecase.loadTrade(tradeID: tradeID)
                userHeartedTrades.append(trade)
            } catch {
                print("Error load to trade that the user hearted: \(error.localizedDescription)")
            }
        }
    }
    
    /*
     // 좋아요, 찜 기능 완료 후 테스트
     func filterUserLikedAndHeartedList() {
     userLikedAccuaArticles = userLikedArticles.filter({ $0.category == .accua})
     userLikedDasiArticles = userLikedArticles.filter({ $0.category == .dasi})
     
     userHeartedNanuaTrades = userHeartedTrades.filter({ $0.category == .nanua})
     userHeartedBaccuaTrades = userHeartedTrades.filter({ $0.category == .baccua})
     }
     */
    
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
