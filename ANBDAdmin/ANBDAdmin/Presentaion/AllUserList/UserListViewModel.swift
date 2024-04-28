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
    @Published var canLoadMoreUsers: Bool = true
    var lastUser: User?
    
    func firstLoadUsers() {
        Task {
            do {
                let users = try await userUsecase.refreshAllUserInfoList(limit: 10)
                DispatchQueue.main.async {
                    self.userList = users
                    self.canLoadMoreUsers = true
                }
            } catch {
                print("사용자 목록을 가져오는데 실패했습니다: \(error)")
            }
        }
    }
    func loadMoreUsers() {
        guard canLoadMoreUsers else { return }
        
        Task {
            do {
                let users = try await userUsecase.getUserInfoList(limit: 11)
                DispatchQueue.main.async {
                    if users.count == 11 {
                        self.lastUser = users.last
                        self.userList.append(contentsOf: users.dropLast())
                        self.canLoadMoreUsers = true
                    } else {
                        if let lastUser = self.lastUser {
                            self.userList.append(lastUser)
                        }
                        self.userList.append(contentsOf: users)
                        self.canLoadMoreUsers = false
                    }
                }
            } catch {
                print("유저 목록을 가져오는데 실패했습니다: \(error)")
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
                self.canLoadMoreUsers = false
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
