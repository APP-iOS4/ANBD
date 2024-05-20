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
                               fcmToken: "",
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
                               fcmToken: "",
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
    
    @Published var blockedUserList: [User] = []
    
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
    
    // MARK: - 사용자 관련 정보 불러오기
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
            #if DEBUG
            print("Failed to get user info: \(error.localizedDescription)")
            #endif
            
            return MyPageViewModel.mockUser
        }
    }
    
    func loadArticleList(of category: ANBDCategory, by userID: String, limit: Int = 10) async -> [Article] {
        do {
            let list = try await articleUsecase.refreshWriterIDArticleList(writerID: userID, category: category, limit: limit)
            
            return list
        } catch {
            #if DEBUG
            print("Failed to load articles: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? ArticleError else {
                ToastManager.shared.toast = Toast(style: .error, message: "게시글 불러오기에 실패하였습니다.")
                return []
            }
            
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
            
            return []
        }
    }
    
    func loadTradeList(of category: ANBDCategory, by userID: String, limit: Int = 10) async -> [Trade] {
        do {
            let list = try await tradeUsecase.refreshWriterIDTradeList(writerID: userID, category: category, limit: limit)
            
            return list
        } catch {
            #if DEBUG
            print("Failed to load trades: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 불러오기에 실패하였습니다.")
                return []
            }
            
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
            
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
                #if DEBUG
                print("Failed to load user liked articles: \(error.localizedDescription)")
                #endif
                
                guard let error = error as? ArticleError else {
                    ToastManager.shared.toast = Toast(style: .error, message: "게시글 불러오기에 실패하였습니다.")
                    return
                }
                
                ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
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
                #if DEBUG
                print("Failed to load user hearted trades: \(error.localizedDescription)")
                #endif
                
                guard let error = error as? TradeError else {
                    ToastManager.shared.toast = Toast(style: .error, message: "거래글 불러오기에 실패하였습니다.")
                    return
                }
                
                ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
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
    
    // MARK: - 사용자 차단하기
    func blockUser(userID: String, blockingUserID: String) async {
        do {
            try await userUsecase.blockUser(userID: userID, blockUserID: blockingUserID)
            
            ToastManager.shared.toast = Toast(style: .success, message: "사용자를 차단하였습니다.")
        } catch {
            #if DEBUG
            print("Failed to block User: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 차단에 실패하였습니다.")
                return
            }
            
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.localizedDescription)")
        }
    }
    
    func unblockUser(userID: String, unblockingUserID: String) async {
        do {
            try await userUsecase.unblockUser(userID: userID, unblockUserID: unblockingUserID)
        } catch {
            #if DEBUG
            print("Failed to unblock User: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 차단 해제에 실패하였습니다.")
                return
            }
            
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.localizedDescription)")
        }
    }
    
    func getBlockList(userID: String, limit: Int = 99) async {
        do {
            blockedUserList = try await userUsecase.refreshBlockUserList(userID: userID, limit: limit)
        } catch {
            #if DEBUG
            print("Failed to retrieve blocked user list: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "차단한 사용자 목록 불러오기에 실패하였습니다.")
                return
            }
            
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.localizedDescription)")
        }
    }
    
    // MARK: - 사용자 정보 수정
    func updateUserProfile(proflieImage: Data?) async {
        do {
            try await userUsecase.updateUserProfile(user: UserStore.shared.user, profileImage: proflieImage)
        } catch {
            #if DEBUG
            print("Failed to update user profile: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 프로필 사진 수정에 실패하였습니다.")
                return
            }
            if error.rawValue == 4009 {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(ID)")
            } else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(이미지)")
            }
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
        if nickname.count > 18 {
            return String(nickname.prefix(18))
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
            #if DEBUG
            print("Failed to update user info: \(error.localizedDescription)")
            #endif
            
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 정보 수정에 실패하였습니다.")
                return
            }
            
            if error.rawValue == 4009 {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(ID)")
            } else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(이미지)")
            }
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
