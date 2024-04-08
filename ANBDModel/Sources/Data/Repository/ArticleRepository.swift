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
    private var accuaQuery: Query?
    private var dasiQuery: Query?
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
        
    func readArticleList() async throws -> [Article] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = articleDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "Article documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.articleDB
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                self?.allQuery = next
                
                let articleList = snapshot.documents.compactMap { try? $0.data(as: Article.self) }
                continuation.resume(returning: articleList)
            }
        }
    }
    
    func readArticleList(category: ANBDCategory) async throws -> [Article] {
        guard category == .accua || category == .dasi else { return [] }
        
        var requestQuery: Query
        
        if category == .accua, let accuaQuery {
            requestQuery = accuaQuery
        } else if category == .dasi, let dasiQuery {
            requestQuery = dasiQuery
        }
        
        requestQuery = articleDB
            .whereField("category", isEqualTo: category)
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "category가 일치하는 Article documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.articleDB
                    .whereField("category", isEqualTo: category)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                if category == .accua {
                    self?.accuaQuery = next
                } else {
                    self?.dasiQuery = next
                }
                    
                let articleList = snapshot.documents.compactMap { try? $0.data(as: Article.self) }
                continuation.resume(returning: articleList)
            }
        }
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
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "writerID가 일치하는 Article documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.articleDB
                    .whereField("writerID", isEqualTo: writerID)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                self?.writerIDQuery = next
                
                let articleList = snapshot.documents.compactMap { try? $0.data(as: Article.self) }
                continuation.resume(returning: articleList)
            }
        }
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
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "keyword에 해당하는 Article documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = filteredQuery.start(afterDocument: lastSnapshot)
                
                self?.searchQuery = next
                
                let articleList = snapshot.documents.compactMap { try? $0.data(as: Article.self) }
                continuation.resume(returning: articleList)
            }
        }
    }
    
    func refreshAll() async throws -> [Article] {
        allQuery = nil
        return try await readArticleList()
    }
    
    func refreshCategory(category: ANBDCategory) async throws -> [Article] {
        guard category == .accua || category == .dasi else { return [] }
        
        if category == .accua {
            accuaQuery = nil
        } else {
            dasiQuery = nil
        }
        
        return try await readArticleList(category: category)
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
        accuaQuery = nil
        dasiQuery = nil
        writerIDQuery = nil
        searchQuery = nil
    }
    
}
