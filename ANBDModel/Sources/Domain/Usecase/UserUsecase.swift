//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation

@available(iOS 15, *)
public protocol UserUsecase {
    func getUserInfo(userID: String) async throws -> User
    func getUserInfoList(limit: Int) async throws -> [User]
    func getBlockList(userID: String, limit: Int) async throws -> [User]
    func refreshAllUserInfoList(limit: Int) async throws -> [User]
    func refreshBlockUserList(userID: String, limit: Int) async throws -> [User]
    func checkDuplicatedNickname(nickname: String) async -> Bool
    func updateUserInfo(user: User) async throws
    func updateUserFCMToken(userID: String, fcmToken: String) async throws
    func updateUserPostCount(user: User,
                             before: ANBDCategory,
                             after: ANBDCategory) async throws
    func updateUserProfile(user: User, profileImage: Data?) async throws
    func blockUser(userID: String, blockUserID: String) async throws
    func unblockUser(userID: String, unblockUserID: String) async throws
}

@available(iOS 15, *)
public struct DefaultUserUsecase: UserUsecase {

    private let userRepository: UserRepository = DefaultUserRepository()
    
    public init() { }
    
    /// User ID가 일치하는 User의 정보를 반환한다.
    public func getUserInfo(userID: String) async throws -> User {
        if userID.isEmpty {
            throw UserError.invalidUserID
        }
        
        let userInfo = try await userRepository.readUserInfo(userID: userID)
        return userInfo
    }
    
    /// [관리자용] 가입된 User의 목록을 반환한다.
    public func getUserInfoList(limit: Int) async throws -> [User] {
        try await userRepository.readUserInfoList(limit: limit)
    }
    
    public func getBlockList(userID: String, limit: Int) async throws -> [User] {
        let blockList = try await userRepository.readUserInfo(userID: userID).blockList
        let blockedUserList = try await userRepository.readBlockList(blockList: blockList, limit: limit)
        return blockedUserList
    }
    
    public func refreshAllUserInfoList(limit: Int) async throws -> [User] {
        try await userRepository.refreshAll(limit: limit)
    }
    
    public func refreshBlockUserList(userID: String, limit: Int) async throws -> [User] {
        let blockList = try await userRepository.readUserInfo(userID: userID).blockList
        let blockedUserList = try await userRepository.refreshBlock(blockList: blockList, limit: limit)
        return blockedUserList
    }
    
    /// User의 정보를 수정한다. (profile, level)
    public func updateUserInfo(user: User) async throws {
        try await userRepository.updateUserInfo(user: user)
    }
    
    public func updateUserFCMToken(userID: String, fcmToken: String) async throws {
        if userID.isEmpty { throw UserError.invalidUserID }
        
        try await userRepository.updateUserFCMToken(userID: userID, fcmToken: fcmToken)
    }
    
    public func updateUserProfile(user: User, profileImage: Data?) async throws {
        var userInfo = user
        
        if let profileImage {
            userInfo.profileImage = try await StorageManager.shared.uploadProfileImage(
                userID: user.id, 
                imageData: profileImage
            )
        }
        
        try await userRepository.updateUserInfo(user: userInfo)
    }
    
    public func updateUserPostCount(
        user: User,
        before: ANBDCategory,
        after: ANBDCategory
    ) async throws {
        if user.id.isEmpty { throw UserError.invalidUserID }
        if before == after { return }
        
        try await userRepository.updateUserPostCount(
            user: user,
            before: before,
            after: after
        )
    }
    
    public func blockUser(userID: String, blockUserID: String) async throws {
        try await userRepository.blockUser(userID: userID, blockUserID: blockUserID)
    }
    
    public func unblockUser(userID: String, unblockUserID: String) async throws {
        try await userRepository.unblockUser(userID: userID, unblockUserID: unblockUserID)
    }
    
    /// 닉네임 중복체크 API
    /// @param nickname 중복여부를 확인할 nickname
    /// @returns 중복된 닉네임일 경우 `true`를, 중복되지 않았을 경우 `false`를 반환한다.
    public func checkDuplicatedNickname(nickname: String) async -> Bool {
        do {
            try await userRepository.checkUser(nickname: nickname)
            return false
        } catch {
            return true
        } 
    }
    
}
