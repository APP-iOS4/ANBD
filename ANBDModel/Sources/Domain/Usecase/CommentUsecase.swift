//
//  CommentUsecase.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

@available(iOS 15, *)
public protocol CommentUsecase {
    func writeComment(articleID: String, comment: Comment) async throws
    func loadCommentList(articleID: String) async throws -> [Comment]
    func updateComment(comment: Comment) async throws
    func deleteComment(articleID: String, commentID: String) async throws
}

@available(iOS 15, *)
public struct DefaultCommentUsecase: CommentUsecase {
    
    let commentRepository: CommentRepository = DefaultCommentRepository()
    
    public init() { }
    
    
    /// articleID가 일치하는 Article에 Comment를 작성하는 메서드
    public func writeComment(articleID: String, comment: Comment) async throws {
        if articleID.isEmpty {
            throw ArticleError.invalidArticleIDField
        }
        
        try await commentRepository.createComment(articleID: articleID, comment: comment)
    }
    
    
    /// articleID가 일치하는 Article의 Comment 배열을 반환하는 메서드
    public func loadCommentList(articleID: String) async throws -> [Comment] {
        if articleID.isEmpty {
            throw ArticleError.invalidArticleIDField
        }
        
        let commentList = try await commentRepository.readCommentList(articleID: articleID)
        return commentList
    }
    
    
    /// Comment를 수정하는 메서드
    public func updateComment(comment: Comment) async throws {
        try await commentRepository.updateComment(comment: comment)
    }
    
    
    /// commentID가 일치하는 Comment를 삭제하는 메서드
    public func deleteComment(articleID: String, commentID: String) async throws {
        if articleID.isEmpty {
            throw ArticleError.invalidArticleIDField
        }
        
        try await commentRepository.deleteComment(articleID: articleID, commentID: commentID)
    }
    
}
