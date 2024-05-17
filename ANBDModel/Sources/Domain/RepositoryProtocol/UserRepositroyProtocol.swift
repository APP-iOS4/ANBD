//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation

@available(iOS 15, *)
public protocol UserRepository {
    func createUserInfo(user: User) async throws -> User
    func readUserInfo(userID: String) async throws -> User
    func readUserInfoList(limit: Int) async throws -> [User]
    func readBlockList(blockList: [String], limit: Int) async throws -> [User]
    func refreshAll(limit: Int) async throws -> [User]
    func refreshBlock(blockList: [String], limit: Int) async throws -> [User]
    func checkUser(email: String) async throws
    func checkUser(nickname: String) async throws
    func updateUserInfo(user: User) async throws
    func updateUserFCMToken(userID: String, fcmToken: String) async throws
    func updateUserPostCount(user: User,
                             before: ANBDCategory,
                             after: ANBDCategory) async throws
    func blockUser(userID: String, blockUserID: String) async throws
    func unblockUser(userID: String, unblockUserID: String) async throws
    func updateUserInfoList(articleID: String) async throws
    func updateUserInfoList(tradeID: String) async throws
    func deleteUserInfo(userID: String) async throws
}
