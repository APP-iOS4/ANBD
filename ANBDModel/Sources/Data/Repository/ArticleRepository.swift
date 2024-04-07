//
//  DefaultArticleRepository.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15, *)
struct DefaultArticleRepository: ArticleRepository {
    
    let articleDB = Firestore.firestore().collection("ArticleBoard")
    
    init() { }
    
    
    // MARK: Create
    func crateArticle(article: Article) async throws {
        guard let _ = try? articleDB.document(article.id).setData(from: article)
        else {
            throw DBError.setDocumentError(message: "Article document를 추가하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Read
    func readArticle(articleID: String) async throws -> Article {
        guard let article = try? await articleDB.document(articleID).getDocument(as: Article.self)
        else {
            throw DBError.getDocumentError(message: "ID가 일치하는 Article document를 읽어오는데 실패했습니다.")
        }
        
        return article
    }
        
    func readArticleList() async throws -> [Article] {
        guard let snapshot = try? await articleDB.order(by: "createdAt", descending: true).getDocuments().documents
        else {
            throw DBError.getDocumentError(message: "Article documents를 읽어오는데 실패했습니다.")
        }
        
        return snapshot.compactMap { try? $0.data(as: Article.self) }
    }
    
    func readArticleList(writerID: String) async throws -> [Article] {
        guard let snapshot = try? await articleDB.whereField("writerID", isEqualTo: writerID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError(message: "writerID가 일치하는 Article documents를 읽어오는데 실패했습니다.")
        }
        
        return snapshot.compactMap { try? $0.data(as: Article.self) }
    }
    
    
    // MARK: Update
    func updateArticle(article: Article) async throws {
        guard let _ = try? await articleDB.document(article.id).setData([
            "category": article.category,
            "title": article.title,
            "content": article.content,
            "imagePaths": article.imagePaths,
            "likeCount": article.likeCount,
            "commentCount": article.commentCount
        ])
        else {
            throw DBError.updateDocumentError(message: "Article document를 업데이트하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Delete
    func deleteArticle(article: Article) async throws {
        guard let _ = try? await articleDB.document(article.id).delete()
        else {
            throw DBError.deleteDocumentError(message: "ID가 일치하는 Article document를 삭제하는데 실패했습니다.")
        }
    }
    
}
