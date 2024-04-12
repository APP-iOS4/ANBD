//
//  CommentRepository.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public protocol CommentRepository {
    func createComment(comment: Comment) async throws
    func readCommentList(articleID: String) async throws -> [Comment]
    func readCommentList(writerID: String) async throws -> [Comment]
    func readCommentList() async throws -> [Comment]
    func updateComment(comment: Comment) async throws
    func deleteComment(commentID: String) async throws
    func deleteCommentList(articleID: String) async throws
}
