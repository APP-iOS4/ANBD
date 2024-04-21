//
//  UserListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/12/24.
//

import SwiftUI
import ANBDModel

class UserListViewModel: ObservableObject {
    @Published var userList: [User] = []
    let userUsecase = DefaultUserUsecase()

    func loadUsers() {
        Task {
            do {
                let users = try await userUsecase.getUserInfoList()
                DispatchQueue.main.async {
                    self.userList = users
                }
            } catch {
                print("사용자 목록을 가져오는데 실패했습니다: \(error)")
            }
        }
    }
    func loadUser(userID: String) async throws -> User {
        return try await userUsecase.getUserInfo(userID: userID)
    }
    func searchUser(userID: String) async {
        do {
            let searchedUser = try await loadUser(userID: userID)
            DispatchQueue.main.async {
                self.userList = [searchedUser]
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.userList = []
            }
        }
    }
}
