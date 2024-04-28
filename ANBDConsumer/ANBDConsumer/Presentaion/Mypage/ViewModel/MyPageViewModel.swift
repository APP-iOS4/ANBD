//
//  MypageViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import Combine
import ANBDModel

@MainActor
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
    
    @Published private(set) var userLikedAccuaArticles: [Article] = []
    @Published private(set) var userLikedDasiArticles: [Article] = []
    @Published private(set) var userHeartedNanuaTrades: [Trade] = []
    @Published private(set) var userHeartedBaccuaTrades: [Trade] = []
    
    @Published var tempUserProfileImage: Data?
    @Published var tempUserNickname = ""
    @Published var tempUserFavoriteLocation: Location = .seoul
    
    @Published private(set) var updatingNicknameStringDebounced = ""
    @Published private(set) var isValidUpdatingNickname = false
    @Published private(set) var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $tempUserNickname
            .removeDuplicates()
            .debounce(for: .seconds(0.02), scheduler: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard let self = self else { return }
                self.updatingNicknameStringDebounced = nickname
            }
            .store(in: &cancellables)
        
        $isValidUpdatingNickname
            .combineLatest($updatingNicknameStringDebounced)
            .map { [weak self] _, nickname in
                guard let self = self else { return false }
                return self.validateUpdatingNickname(nickname: nickname)
            }
            .assign(to: &$isValidUpdatingNickname)
    }
    
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
    
    func loadAllUserActivityList(by userID: String) async {
        accuaArticlesWrittenByUser = await loadArticleList(of: .accua, by: userID)
        dasiArticlesWrittenByUser = await loadArticleList(of: .dasi, by: userID)
        
        nanuaTradesWrittenByUser = await loadTradeList(of: .nanua, by: userID)
        baccuaTradesWrittenByUser = await loadTradeList(of: .baccua, by: userID)
    }
    
    func loadUserLikedArticles(user: User) async {
        var articles: [Article] = []
        
        for articleID in user.likeArticles {
            do {
                let article = try await articleUsecase.loadArticle(articleID: articleID)
                articles.append(article)
            } catch {
                print("Error load to article that the user likes: \(error.localizedDescription)")
            }
        }
        userLikedArticles = articles
    }
    
    func loadUserHeartedTrades(user: User) async {
        var trades: [Trade] = []
        
        for tradeID in user.likeTrades {
            do {
                let trade = try await tradeUsecase.loadTrade(tradeID: tradeID)
                trades.append(trade)
            } catch {
                print("Error load to trade that the user hearted: \(error.localizedDescription)")
            }
        }
        userHeartedTrades = trades
    }
    
    func filterUserLikedAndHeartedList() {
        userLikedAccuaArticles = userLikedArticles.filter({ $0.category == .accua})
        userLikedDasiArticles = userLikedArticles.filter({ $0.category == .dasi})
        
        userHeartedNanuaTrades = userHeartedTrades.filter({ $0.category == .nanua})
        userHeartedBaccuaTrades = userHeartedTrades.filter({ $0.category == .baccua})
    }
    
    // MARK: - 유저 정보 수정
    func updateUserProfile(proflieImage: Data?) async {
        do {
            try await userUsecase.updateUserProfile(user: UserStore.shared.user, profileImage: proflieImage)
        } catch {
            print("Error update user profile image: \(error.localizedDescription)")
        }
    }
    
    func checkDuplicatedNickname() async -> Bool {
        if tempUserNickname == user.nickname {
            return false
        } else {
            let isDuplicate = await userUsecase.checkDuplicatedNickname(nickname: tempUserNickname)
            
            return isDuplicate
        }
    }
    
    func checkNicknameLength(_ nickname: String) -> String {
        if nickname.count > 20 {
            return String(nickname.prefix(20))
        } else {
            return nickname
        }
    }
    
    func validateUpdatingNickname(nickname: String) -> Bool {
        if !nickname.isEmpty && !nickname.isValidateNickname() {
            errorMessage = "잘못된 닉네임 형식입니다."
        } else {
            errorMessage = ""
        }
        
        return !nickname.isEmpty && nickname.isValidateNickname()
    }
    
    func validateUpdatingComplete() -> Bool {
        if (tempUserProfileImage == nil) && (user.nickname == tempUserNickname) && (user.favoriteLocation == tempUserFavoriteLocation) {
            return false
        } else if tempUserNickname.isEmpty {
            return false
        } else if !isValidUpdatingNickname {
            return false
        } else {
            return true
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
    
    // MARK: - 설정
    func getCurrentAppVersion() -> String {
        if let info: [String: Any] = Bundle.main.infoDictionary,
           let currentVersion: String = info["CFBundleShortVersionString"] as? String {
            return currentVersion
        }
        
        return "nil"
    }
}
