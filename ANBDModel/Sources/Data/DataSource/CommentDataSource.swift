//
//  CommentDataSource.swift
//
//
//  Created by 유지호 on 4/13/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
protocol CommentDataSource {
    func createComment(comment: Comment) async throws
    func readComment(commentID: String) async throws -> Comment
    func readCommentList(articleID: String) async throws -> [Comment]
    func readCommentList(writerID: String) async throws -> [Comment]
    func readCommentList() async throws -> [Comment]
    func updateComment(comment: Comment) async throws
    func deleteComment(commentID: String) async throws
    func deleteCommentList(articleID: String) async throws
}

@available(iOS 15, *)
struct DefaultCommentDataSource: CommentDataSource {
    
    private let commentDB = Firestore.firestore().collection("Comment")
    
    init() {
        print("Comment DataSource init")
    }
    
    
    // MARK: Create
    /// CommentDB에 댓글 정보를 추가합니다.
    func createComment(comment: Comment) async throws {
        guard let _ = try? commentDB.document(comment.id).setData(from: comment)
        else {
            throw DBError.setCommentDocumentError
        }
    }
    
    
    // MARK: Read
    /// commentID가 일치하는 댓글을 반환한다.
    func readComment(commentID: String) async throws -> Comment {
        guard let comment = try? await commentDB.document(commentID).getDocument(as: Comment.self)
        else {
            throw DBError.getCommentDocumentError
        }
        
        return comment
    }
    
    /// articleID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(articleID: String) async throws -> [Comment] {
        guard let snapshot = try? await commentDB
            .whereField("articleID", isEqualTo: articleID)
            .getDocuments()
            .documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        return snapshot.compactMap { try? $0.data(as: Comment.self) }
    }
    
    /// writerID가 일치하는 댓글 목록을 반환한다.
    func readCommentList(writerID: String) async throws -> [Comment] {
        guard let snapshot = try? await commentDB
            .whereField("writerID", isEqualTo: writerID)
            .getDocuments()
            .documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        return snapshot.compactMap { try? $0.data(as: Comment.self) }
    }
    
    /// [관리자용]
    /// 전체 댓글 목록을 반환한다.
    func readCommentList() async throws -> [Comment] {
        guard let snapshot = try? await commentDB.getDocuments().documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        return snapshot.compactMap { try? $0.data(as: Comment.self) }
    }
    
    
    // MARK: Update
    /// 댓글 정보를 수정한다.
    func updateComment(comment: Comment) async throws {
        guard let _ = try? await commentDB
            .document(comment.id)
            .updateData(["content": comment.content])
        else {
            throw DBError.updateCommentDocumentError
        }
    }
    
    
    // MARK: Delete
    func deleteComment(commentID: String) async throws {
        guard let _ = try? await commentDB.document(commentID).delete()
        else {
            throw DBError.deleteCommentDocumentError
        }
    }
    
    func deleteCommentList(articleID: String) async throws {
        guard let snapshot = try? await commentDB
            .whereField("articleID", isEqualTo: articleID)
            .getDocuments()
            .documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        let commentList = snapshot.compactMap { try? $0.data(as: Comment.self) }
        
        for comment in commentList {
            try await deleteComment(commentID: comment.id)
        }
    }
    
}
