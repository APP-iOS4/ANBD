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
    func deleteComment(commentID: String) async throws
}

@available(iOS 15, *)
public struct DefaultCommentUsecase: CommentUsecase {
    
    let articleRepository: ArticleRepository = DefaultArticleRepository()
    let commentRepository: CommentRepository = DefaultCommentRepository()
    
    public init() { }
    
    
    /// articleID가 일치하는 Article에 Comment를 작성하는 메서드
    public func writeComment(articleID: String, comment: Comment) async throws {
        var articleInfo = try await articleRepository.readArticle(articleID: articleID)
        
        try await commentRepository.createComment(comment: comment)
        articleInfo.commentCount += 1
        
        try await articleRepository.updateArticle(article: articleInfo)
    }
    
    
    /// articleID가 일치하는 Article의 Comment 배열을 반환하는 메서드
    public func loadCommentList(articleID: String) async throws -> [Comment] {
        try await commentRepository.readCommentList(articleID: articleID)
    }
    
    
    /// Comment를 수정하는 메서드
    public func updateComment(comment: Comment) async throws {
        try await commentRepository.updateComment(comment: comment)
    }
    
    
    /// commentID가 일치하는 Comment를 삭제하는 메서드
    public func deleteComment(commentID: String) async throws {
        try await commentRepository.deleteComment(commentID: commentID)
    }
    
}
