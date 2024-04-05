//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation

public protocol UserRepository {
    func createUserInfo(user: User) async throws -> User
    func readUserInfo(userID: String) async throws -> User
    func readUserInfoList() async throws -> [User]
    func checkUser(email: String) async throws
    func checkUser(nickname: String) async throws
    func updateUserInfo(user: User) async throws
    func updateUserInfoList(articleID: String) async throws
    func deleteUserInfo(userID: String) async throws
}
