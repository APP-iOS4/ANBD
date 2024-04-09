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
final class DefaultArticleRepository: ArticleRepository {
    
    let articleDB = Firestore.firestore().collection("ArticleBoard")
    
    private var allQuery: Query?
    private var writerIDQuery: Query?
    private var searchQuery: Query?
    
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
    
    func readRecentArticle(category: ANBDCategory) async throws -> Article {
        guard category == .accua || category == .dasi else {
            throw NSError(domain: "Recent Article Category Error", code: 4011)
        }
        
        let query = articleDB
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
        
        guard let article = try? await query
            .getDocuments()
            .documents
            .first?
            .data(as: Article.self)
        else {
            throw DBError.getDocumentError(message: "최근 Article을 읽어오는데 실패했습니다.")
        }
        
        return article
    }
        
    func readArticleList() async throws -> [Article] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = articleDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = articleDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Article.self) }
    }
    
    func readArticleList(writerID: String) async throws -> [Article] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = articleDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = articleDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Article.self) }
    }
    
    func readArticleList(keyword: String) async throws -> [Article] {
        guard !keyword.isEmpty else { return [] }
        
        var requestQuery: Query
        let filteredQuery = articleDB
            .whereFilter(
                .orFilter([
                    .andFilter([
                        .whereField("title", isGreaterOrEqualTo: keyword),
                        .whereField("title", isLessThan: keyword + "힣")
                    ]),
                    .andFilter([
                        .whereField("content", isGreaterOrEqualTo: keyword),
                        .whereField("content", isLessThan: keyword + "힣")
                    ])
                ])
            )
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
        
        if let searchQuery {
            requestQuery = searchQuery
        } else {
            requestQuery = filteredQuery
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = filteredQuery
                .start(afterDocument: lastSnapshot)
            
            searchQuery = next
        }
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Article.self) }
    }
    
    func refreshAll() async throws -> [Article] {
        allQuery = nil
        return try await readArticleList()
    }
    
    func refreshWriterID(writerID: String) async throws -> [Article] {
        writerIDQuery = nil
        return try await readArticleList(writerID: writerID)
    }
    
    func refreshSearch(keyword: String) async throws -> [Article] {
        guard !keyword.isEmpty else { return [] }
        searchQuery = nil
        return try await readArticleList(keyword: keyword)
    }
    
    
    // MARK: Update
    func updateArticle(article: Article) async throws {
        guard let _ = try? await articleDB.document(article.id).updateData([
            "category": article.category.rawValue,
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
    
    func resetQuery() {
        allQuery = nil
        writerIDQuery = nil
        searchQuery = nil
    }
    
}
