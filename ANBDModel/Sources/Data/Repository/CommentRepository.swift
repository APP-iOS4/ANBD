//
//  DefaultCommentRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
struct DefaultCommentRepository: CommentRepository {
    
    private let commentDataSource: CommentDataSource
    private let articleDataSource: any ArticleDataSource
    
    init(
        commentDataSource: CommentDataSource = DefaultCommentDataSource(),
        articleDataSource: any ArticleDataSource = DefaultArticleDataSource()
    ) {
        self.commentDataSource = commentDataSource
        self.articleDataSource = articleDataSource
    }
    
    
    // MARK: Create
    /// CommentDB에 댓글 정보를 추가합니다.
    func createComment(articleID: String, comment: Comment) async throws {
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        
        try await commentDataSource.createComment(comment: comment)
        articleInfo.commentCount += 1
        
        try await articleDataSource.updateItem(item: articleInfo)
    }
    
    
    // MARK: Read
    /// commentID가 일치하는 댓글을 반환한다.
    func readCommentList(commentID: String) async throws -> Comment {
        let comment = try await commentDataSource.readComment(commentID: commentID)
        return comment
    }
    
    /// articleID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(articleID: String) async throws -> [Comment] {
        let commentList = try await commentDataSource.readCommentList(articleID: articleID)
        return commentList
    }
    
    /// writerID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(writerID: String) async throws -> [Comment] {
        let commentList = try await commentDataSource.readCommentList(writerID: writerID)
        return commentList
    }
    
    /// [관리자용]
    /// 전체 댓글 목록을 반환한다.
    func readCommentList() async throws -> [Comment] {
        let commentList = try await commentDataSource.readCommentList()
        return commentList
    }
    
    
    // MARK: Update
    /// 댓글 정보를 수정한다.
    func updateComment(comment: Comment) async throws {
        try await commentDataSource.updateComment(comment: comment)
    }
    
    
    // MARK: Delete
    func deleteComment(articleID: String, commentID: String) async throws {
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        
        try await commentDataSource.deleteComment(commentID: commentID)
        articleInfo.commentCount -= 1
        
        try await articleDataSource.updateItem(item: articleInfo)
    }
    
    func deleteCommentList(articleID: String) async throws {
        try await commentDataSource.deleteCommentList(articleID: articleID)
    }
    
}
