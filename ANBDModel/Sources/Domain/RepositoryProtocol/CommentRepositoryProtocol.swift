//
//  CommentRepository.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public protocol CommentRepository {
    func createComment(articleID: String, comment: Comment) async throws
    func readComment(commentID: String) async throws -> Comment
    func readCommentList(articleID: String) async throws -> [Comment]
    func readCommentList(writerID: String, limit: Int) async throws -> [Comment]
    func updateComment(comment: Comment) async throws
    func deleteComment(articleID: String, commentID: String) async throws
    func deleteCommentList(articleID: String) async throws
}
