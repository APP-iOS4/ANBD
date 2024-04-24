//
//  UserDataSource.swift
//
//
//  Created by 유지호 on 4/14/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15.0, *)
protocol UserDataSource {
    func createUserInfo(user: User) async throws -> User
    func readUserInfo(userID: String) async throws -> User
    func readUserInfoList(limit: Int) async throws -> [User]
    func refreshAll(limit: Int) async throws -> [User]
    func checkUser(email: String) async throws
    func checkUser(nickname: String) async throws
    func updateUserInfo(user: User) async throws
    func updateUserPostCount(user: User) async throws
    func updateUserInfoList(articleID: String) async throws
    func updateUserInfoList(tradeID: String) async throws
    func deleteUserInfo(userID: String) async throws
}

@available(iOS 15.0, *)
final class DefaultUserDataSource: UserDataSource {
    
    private let userDB = Firestore.firestore().collection("User")
    
    private var allQuery: Query?
    
    init() { }
    
    
    // MARK: Create
    func createUserInfo(user: User) async throws -> User {
        guard let _ = try? userDB.document(user.id).setData(from: user)
        else {
            throw DBError.setUserDocumentError
        }
        
        return user
    }
    
    
    // MARK: Read
    func readUserInfo(userID: String) async throws -> User {
        guard let userInfo = try? await userDB.document(userID).getDocument(as: User.self)
        else {
            throw DBError.getUserDocumentError
        }
        
        return userInfo
    }
    
    func readUserInfoList(limit: Int) async throws -> [User] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = userDB
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = requestQuery.start(afterDocument: lastSnapshot)
            self.allQuery = next
        }
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError
        }
        
        let userInfoList = snapshot.compactMap { try? $0.data(as: User.self) }
        return userInfoList
    }
    
    func refreshAll(limit: Int) async throws -> [User] {
        allQuery = nil
        return try await readUserInfoList(limit: limit)
    }
    
    func checkUser(email: String) async throws {
        let snapshot = try await userDB.whereField("email", isEqualTo: email).getDocuments()
        
        if snapshot.count > 0 {
            throw AuthError.duplicatedEmail
        }
    }
    
    func checkUser(nickname: String) async throws {
        let snapshot = try await userDB.whereField("nickname", isEqualTo: nickname).getDocuments()
        
        if snapshot.count > 0 {
            throw AuthError.duplicatedNickname
        }
    }
    
    
    // MARK: Update
    func updateUserInfo(user: User) async throws {
        guard let _ = try? await userDB.document(user.id).updateData([
            "nickname": user.nickname,
            "favoriteLocation": user.favoriteLocation.rawValue,
            "userLevel": user.userLevel.rawValue,
            "isAgreeMarketing": user.isAgreeMarketing,
            "likeArticles": user.likeArticles,
            "likeTrades": user.likeTrades,
            "profileImage": user.profileImage
        ])
        else {
            throw DBError.updateUserDocumentError
        }
    }
    
    func updateUserPostCount(user: User) async throws {
        guard let _ = try? await userDB.document(user.id).updateData([
            "accuaCount": user.accuaCount,
            "nanuaCount": user.nanuaCount,
            "baccuaCount": user.baccuaCount,
            "dasiCount": user.dasiCount
        ])
        else {
            throw DBError.updateDocumentError
        }
    }
    
    /// 좋아요한 게시글이 삭제됐을 때 User의 좋아요한 배열에서 삭제하는 메서드
    func updateUserInfoList(articleID: String) async throws {
        guard let snapshot = try? await userDB.whereField("likeArticles", arrayContains: articleID).getDocuments().documents
        else {
            throw DBError.getUserDocumentError
        }
        
        let userInfoList = snapshot.compactMap { try? $0.data(as: User.self) }
        
        for userInfo in userInfoList {
            var updatingUserInfo = userInfo
            updatingUserInfo.likeArticles = userInfo.likeArticles.filter { $0 != articleID }
            
            try await updateUserInfo(user: updatingUserInfo)
        }
    }
    
    func updateUserInfoList(tradeID: String) async throws {
        guard let snapshot = try? await userDB.whereField("likeTrades", arrayContains: tradeID).getDocuments().documents
        else {
            throw DBError.getUserDocumentError
        }
        
        let userInfoList = snapshot.compactMap { try? $0.data(as: User.self) }
        
        for userInfo in userInfoList {
            var updatingUserInfo = userInfo
            updatingUserInfo.likeTrades = userInfo.likeTrades.filter { $0 != tradeID }
            
            try await updateUserInfo(user: updatingUserInfo)
        }
    }
    
    
    // MARK: Delete
    func deleteUserInfo(userID: String) async throws {
        guard let _ = try? await userDB.document(userID).delete()
        else {
            throw DBError.deleteUserDocumentError
        }
    }
    
}
