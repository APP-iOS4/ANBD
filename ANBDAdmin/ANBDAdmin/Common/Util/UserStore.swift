//
//  UserStore.swift
//  ANBDAdmin
//
//  Created by 김성민 on 4/20/24.
//

import Foundation
import ANBDModel

final class UserStore: ObservableObject {
    static let shared = UserStore()
    
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    
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
    
    private init() {
        Task {
            user = await getUserInfo(userID: UserDefaultsClient.shared.userID ?? "abcd1234")
        }
    }
    
    func getUserInfo(userID: String) async -> User {
        do {
            let getUser = try await userUsecase.getUserInfo(userID: userID)
            self.user = getUser
            return getUser
        } catch {
            print("Error get user information: \(error.localizedDescription)")
            
            return await MyPageViewModel.mockUser
        }
    }
    
    func updateLocalUserInfo() async {
        do {
            guard let userID = UserDefaultsClient.shared.userID else { return }
            self.user = try await userUsecase.getUserInfo(userID: userID)
        } catch {
            print("Error save user information: \(error.localizedDescription)")
        }
    }
}
