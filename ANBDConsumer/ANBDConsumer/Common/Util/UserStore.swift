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
    
    var deviceToken: String = ""
    
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
            guard let error = error as? UserError else {
                return await MyPageViewModel.mockUser
            }
            if error.rawValue == 4009 {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(ID)")
            } else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(이미지)")
            }
            
            return await MyPageViewModel.mockUser
        }
    }
    
    func updateLocalUserInfo() async {
        do {
            guard let userID = UserDefaultsClient.shared.userID else { return }
            self.user = try await userUsecase.getUserInfo(userID: userID)
        } catch {
            guard let error = error as? UserError else {
                ToastManager.shared.toast = Toast(style: .error, message: "유저 정보 저장에 실패하였습니다.")
                return
            }
            if error.rawValue == 4009 {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(ID)")
            } else {
                ToastManager.shared.toast = Toast(style: .error, message: "사용자 필드 누락(이미지)")
            }
        }
    }
}
