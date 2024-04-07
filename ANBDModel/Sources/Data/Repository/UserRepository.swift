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
    
    let userDB = Firestore.firestore().collection("User")
    
    init() { }
    
    
    // MARK: Create
    func createUserInfo(user: User) async throws -> User {
        guard let _ = try? userDB.document(user.id).setData(from: user)
        else {
            throw DBError.setDocumentError(message: "User document를 추가하는데 실패했습니다.")
        }
        
        return user
    }
    
    
    // MARK: Read
    func readUserInfo(userID: String) async throws -> User {
        guard let userInfo = try? await userDB.document(userID).getDocument(as: User.self)
        else {
            throw DBError.getDocumentError(message: "ID가 일치하는 User document를 읽어오는데 실패했습니다.")
        }
        
        return userInfo
    }
    
    func readUserInfoList() async throws -> [User] {
        guard let snapshot = try? await userDB.getDocuments()
        else {
            throw DBError.getDocumentError(message: "User documents를 읽어오는데 실패했습니다.")
        }
        
        return try snapshot.documents.compactMap { try $0.data(as: User.self) }
    }
    
    func checkUser(email: String) async throws {
        let snapshot = try await userDB.whereField("email", isEqualTo: email).getDocuments()
        
        if snapshot.count > 0 {
            throw AuthError.duplicatedEmail(message: "중복된 이메일입니다.")
        }
    }
    
    func checkUser(nickname: String) async throws {
        let snapshot = try await userDB.whereField("nickname", isEqualTo: nickname).getDocuments()
        
        if snapshot.count > 0 {
            throw AuthError.duplicatedNickname(message: "중복된 닉네임입니다.")
        }
    }
    
    
    // MARK: Update
    func updateUserInfo(user: User) async throws {
        guard let _ = try? await userDB.document(user.id).updateData([
            "nickname": user.nickname,
            "favoriteLocation": user.favoriteLocation,
            "userLevel": user.userLevel.rawValue,
            "isAgreeMarketing": user.isAgreeMarketing,
            "likeArticles": user.likeArticles,
            "likeTrades": user.likeTrades
        ])
        else {
            throw DBError.updateDocumentError(message: "User 정보를 업데이트하는데 실패했습니다.")
        }
    }
    
    /// 좋아요한 게시글이 삭제됐을 때 User의 좋아요한 배열에서 삭제하는 메서드
    func updateUserInfoList(articleID: String) async throws {
        guard let snapshot = try? await userDB.whereField("likedArticles", arrayContains: articleID).getDocuments().documents
        else {
            throw DBError.getDocumentError(message: "articleID를 좋아요한 User documents를 읽어오는데 실패했습니다.")
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
            throw DBError.getDocumentError(message: "tradeID를 좋아요한 User documents를 읽어오는데 실패했습니다.")
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
            throw DBError.deleteDocumentError(message: "User 정보를 삭제하는데 실패했습니다.")
        }
    }
    
}
