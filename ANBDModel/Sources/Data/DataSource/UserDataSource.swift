//
//  File.swift
//  
//
//  Created by 유지호 on 4/3/24.
//

import Foundation
import FirebaseFirestore

public protocol UserDataSource {
    func createUserInfo(user: User) async throws -> User
    func readUserInfo(userID: String) async throws -> User
    func updateUserInfo(user: User) async throws
    func deleteUserInfo(userID: String) async throws
}

@available(iOS 13, *)
public struct DefaultUserDataSource: UserDataSource {

    let userDB = Firestore.firestore().collection("User")
    
    public init() { }
    
    public func createUserInfo(user: User) async throws -> User {
        try userDB.document(user.id).setData(from: user)
        return user
    }
    
    public func readUserInfo(userID: String) async throws -> User {
        try await userDB.document(userID).getDocument(as: User.self)
    }
    
    public func updateUserInfo(user: User) async throws {
        try await userDB.document(user.id).updateData([
            "nickname": user.nickname,
            "userLevel": user.userLevel,
            "isAgreeMarketing": user.isAgreeMarketing,
            "likeArticles": user.likeArticles,
            "likeTrades": user.likeTrades
        ])
    }
    
    public func deleteUserInfo(userID: String) async throws {
        try await userDB.document(userID).delete()
    }
    
}
