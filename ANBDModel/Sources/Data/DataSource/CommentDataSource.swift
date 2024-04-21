//
//  CommentDataSource.swift
//
//
//  Created by 유지호 on 4/13/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
extension Postable where Item == Comment {
    
    func readItemList(articleID: String) async throws -> [Comment] {
        guard let snapshot = try? await database
            .whereField("articleID", isEqualTo: articleID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        return snapshot.compactMap { try? $0.data(as: Comment.self) }
    }
    
    func updateItem(item: Comment) async throws {
        guard let _ = try? await database
            .document(item.id)
            .updateData(["content": item.content])
        else {
            throw DBError.updateCommentDocumentError
        }
    }
    
    func deleteItemList(articleID: String) async throws {
        guard let snapshot = try? await database
            .whereField("articleID", isEqualTo: articleID)
            .getDocuments()
            .documents
        else {
            throw DBError.getCommentDocumentError
        }
        
        let commentList = snapshot.compactMap { try? $0.data(as: Comment.self) }
        
        for comment in commentList {
            try await deleteItem(itemID: comment.id)
        }
    }
    
}
