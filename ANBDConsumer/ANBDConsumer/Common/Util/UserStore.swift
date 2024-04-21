//
//  UserStore.swift
//  ANBDConsumer
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
                               isOlderThanFourteen: false,
                               isAgreeService: false,
                               isAgreeCollectInfo: false,
                               isAgreeMarketing: false,
                               likeArticles: [],
                               likeTrades: [])
    init() {
        Task {
            user = await getUserInfo(userID: UserDefaultsClient.shared.userID ?? "abcd1234")
        }
    }
    
    func getUserInfo(userID: String) async -> User {
        do {
            let getUser = try await userUsecase.getUserInfo(userID: userID)
            
            return getUser
        } catch {
            print("Error get user information: \(error.localizedDescription)")
            
            return MyPageViewModel.mockUser
        }
    }
}