//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
struct DefaultUserRepository: UserRepository {
    
    private let userDataSource: UserDataSource
    
    init(userDataSource: UserDataSource = DefaultUserDataSource()) {
        self.userDataSource = userDataSource
    }
    
    
    // MARK: Create
    func createUserInfo(user: User) async throws -> User {
        let user = try await userDataSource.createUserInfo(user: user)
        return user
    }
    
    
    // MARK: Read
    func readUserInfo(userID: String) async throws -> User {
        let userInfo = try await userDataSource.readUserInfo(userID: userID)
        return userInfo
    }
    
    func readUserInfoList() async throws -> [User] {
        let userInfoList = try await userDataSource.readUserInfoList()
        return userInfoList
    }
    
    func checkUser(email: String) async throws {
        try await userDataSource.checkUser(email: email)
    }
    
    func checkUser(nickname: String) async throws {
        try await userDataSource.checkUser(nickname: nickname)
    }
    
    
    // MARK: Update
    func updateUserInfo(user: User) async throws {
        try await userDataSource.updateUserInfo(user: user)
    }
    
    /// 좋아요한 게시글이 삭제됐을 때 User의 좋아요한 배열에서 삭제하는 메서드
    func updateUserInfoList(articleID: String) async throws {
        try await userDataSource.updateUserInfoList(articleID: articleID)
    }
    
    func updateUserInfoList(tradeID: String) async throws {
        try await userDataSource.updateUserInfoList(tradeID: tradeID)
    }
    
    
    // MARK: Delete
    func deleteUserInfo(userID: String) async throws {
        try await userDataSource.deleteUserInfo(userID: userID)
    }
    
}
