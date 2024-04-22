//
//  DefaultCommentRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
struct CommentRepositoryImpl: CommentRepository {
    
    private let commentDataSource: any Postable<Comment>
    private let articleDataSource: any Postable<Article>
    
    init(
        commentDataSource: any Postable<Comment> = PostDataSource<Comment>(database: .commentDatabase),
        articleDataSource: any Postable<Article> = PostDataSource<Article>(database: .articleDatabase)
    ) {
        self.commentDataSource = commentDataSource
        self.articleDataSource = articleDataSource
    }
    
    
    // MARK: Create
    func createComment(articleID: String, comment: Comment) async throws {
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        
        try await commentDataSource.createItem(item: comment)
        articleInfo.commentCount += 1
        
        try await articleDataSource.updateItem(item: articleInfo)
    }
    
    
    // MARK: Read
    func readComment(commentID: String) async throws -> Comment {
        let comment = try await commentDataSource.readItem(itemID: commentID)
        return comment
    }
    
    func readCommentList(articleID: String) async throws -> [Comment] {
        let commentList = try await commentDataSource.readItemList(articleID: articleID)
        return commentList
    }
    
    func readCommentList(writerID: String, limit: Int) async throws -> [Comment] {
        let commentList = try await commentDataSource.readItemList(writerID: writerID, category: nil, limit: limit)
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
