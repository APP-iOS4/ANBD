//
//  DefaultCommentRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15, *)
struct CommentRepositoryImpl: CommentRepository {
    
    private let userDataSource: UserDataSource
    private let commentDataSource: any Postable<Comment>
    private let articleDataSource: any Postable<Article>
    
    init(
        userDataSource: UserDataSource = DefaultUserDataSource(),
        commentDataSource: any Postable<Comment> = PostDataSource<Comment>(database: .commentDatabase),
        articleDataSource: any Postable<Article> = PostDataSource<Article>(database: .articleDatabase)
    ) {
        self.userDataSource = userDataSource
        self.commentDataSource = commentDataSource
        self.articleDataSource = articleDataSource
    }
    
    
    // MARK: Create
    func createComment(articleID: String, comment: Comment) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw UserError.invalidUserID
        }
        
        let userInfo = try await userDataSource.readUserInfo(userID: userID)
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        let writerInfo = try await userDataSource.readUserInfo(userID: articleInfo.writerID)
        
        try await commentDataSource.createItem(item: comment)
        articleInfo.commentCount += 1
        
        await NotificationManager.shared.sendCommentNotification(
            from: userInfo,
            to: writerInfo.fcmToken,
            article: articleInfo,
            comment: comment
        )
        
        try await articleDataSource.updateItem(item: articleInfo)
    }
    
    
    // MARK: Read
    func readComment(commentID: String) async throws -> Comment {
        let comment = try await commentDataSource.readItem(itemID: commentID)
        return comment
    }
    
    func readCommentList(articleID: String) async throws -> [Comment] {
        var blockList: [String] = []
        
        if let userID = Auth.auth().currentUser?.uid {
            blockList = try await userDataSource.readUserInfo(userID: userID).blockList
        }
        
        let commentList = try await commentDataSource.readItemList(articleID: articleID, blockList: blockList)
        return commentList
    }
    
    func readCommentList(writerID: String, limit: Int) async throws -> [Comment] {
        var blockList: [String] = []
        
        if let userID = Auth.auth().currentUser?.uid {
            blockList = try await userDataSource.readUserInfo(userID: userID).blockList
        }
        
        let commentList = try await commentDataSource.readItemList(writerID: writerID, category: nil, blockList: blockList, limit: limit)
        return commentList
    }
    
    func readAllCommentList(writerID: String) async throws -> [Comment] {
        let commentList = try await commentDataSource.readAllItemList(writerID: writerID)
        return commentList
    }
    
    
    // MARK: Update
    func updateComment(comment: Comment) async throws {
        try await commentDataSource.updateItem(item: comment)
    }
    
    
    // MARK: Delete
    func deleteComment(articleID: String, commentID: String) async throws {
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        
        try await commentDataSource.deleteItem(itemID: commentID)
        articleInfo.commentCount -= 1
        
        try await articleDataSource.updateItem(item: articleInfo)
    }
    
    func deleteCommentList(articleID: String) async throws {
        try await commentDataSource.deleteItemList(articleID: articleID)
    }
    
}
