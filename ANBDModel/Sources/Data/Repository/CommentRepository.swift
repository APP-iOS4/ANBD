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
    private let articleDataSource: ArticleDataSource
    
    init(
        commentDataSource: CommentDataSource = DefaultCommentDataSource(),
        articleDataSource: ArticleDataSource = DefaultArticleDataSource()
    ) {
        self.commentDataSource = commentDataSource
        self.articleDataSource = articleDataSource
    }
    
    
    // MARK: Create
    /// CommentDB에 댓글 정보를 추가합니다.
    func createComment(articleID: String, comment: Comment) async throws {
        do {
            var articleInfo = try await articleDataSource.readArticle(articleID: articleID)
            
            try await commentDataSource.createComment(comment: comment)
            articleInfo.commentCount += 1
            
            try await articleDataSource.updateArticle(article: articleInfo)
        } catch DBError.setDocumentError {
            throw CommentError.createCommentError(code: 4021, message: "Comment를 추가하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Read
    /// commentID가 일치하는 댓글을 반환한다.
    func readCommentList(commentID: String) async throws -> Comment {
        do {
            let comment = try await commentDataSource.readComment(commentID: commentID)
            return comment
        } catch DBError.getDocumentError {
            throw CommentError.createCommentError(code: 4022, message: "Comment를 읽어오는데 실패했습니다.")
        }
    }
    
    /// articleID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(articleID: String) async throws -> [Comment] {
        do {
            let commentList = try await commentDataSource.readCommentList(articleID: articleID)
            return commentList
        } catch DBError.getDocumentError {
            throw CommentError.createCommentError(code: 4022, message: "Comment를 읽어오는데 실패했습니다.")
        }
    }
    
    /// writerID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(writerID: String) async throws -> [Comment] {
        do {
            let commentList = try await commentDataSource.readCommentList(writerID: writerID)
            return commentList
        } catch DBError.getDocumentError {
            throw CommentError.createCommentError(code: 4022, message: "Comment를 읽어오는데 실패했습니다.")
        }
    }
    
    /// [관리자용]
    /// 전체 댓글 목록을 반환한다.
    func readCommentList() async throws -> [Comment] {
        do {
            let commentList = try await commentDataSource.readCommentList()
            return commentList
        } catch DBError.getDocumentError {
            throw CommentError.createCommentError(code: 4022, message: "Comment를 읽어오는데 실패했습니다.")
        }
    }
    
    
    // MARK: Update
    /// 댓글 정보를 수정한다.
    func updateComment(comment: Comment) async throws {
        do {
            try await commentDataSource.updateComment(comment: comment)
        } catch DBError.updateDocumentError {
            throw CommentError.updateCommentError(code: 4023, message: "Comment를 업데이트하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Delete
    func deleteComment(articleID: String, commentID: String) async throws {
        do {
            var articleInfo = try await articleDataSource.readArticle(articleID: articleID)
            
            try await commentDataSource.deleteComment(commentID: commentID)
            articleInfo.commentCount -= 1
            
            try await articleDataSource.updateArticle(article: articleInfo)
        } catch DBError.deleteDocumentError {
            throw CommentError.deleteCommentError(code: 4024, message: "Comment를 삭제하는데 실패했습니다.")
        }
    }
    
    func deleteCommentList(articleID: String) async throws {
        do {
            try await commentDataSource.deleteCommentList(articleID: articleID)
        } catch DBError.deleteDocumentError {
            throw CommentError.deleteCommentError(code: 4024, message: "Comment를 삭제하는데 실패했습니다.")
        }
    }
    
}
