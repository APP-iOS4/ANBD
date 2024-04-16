//
//  ArticleDataSource.swift
//
//
//  Created by 유지호 on 4/13/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
protocol ArticleDataSource: Postable where Item == Article {
    func readRecentItem(category: ANBDCategory) async throws -> Article
    func readItemList(category: ANBDCategory,
                         by order: ArticleOrder,
                         limit: Int) async throws -> [Article]
    func refreshOrder(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article]
}

@available(iOS 15, *)
final class DefaultArticleDataSource: ArticleDataSource {

    private let articleDB = Firestore.firestore().collection("ArticleBoard")
    
    private var allQuery: Query?
    private var writerIDQuery: Query?
    private var orderQuery: Query?
    private var searchQuery: Query?
    
    init() {
        #if DEBUG
        print("Article DataSource init")
        #endif
    }
    
    deinit {
        #if DEBUG
        print("Article DataSource deinit")
        #endif
    }

    
    // MARK: Create
    func createItem(item: Article) async throws {
        guard let _ = try? articleDB.document(item.id).setData(from: item)
        else {
            throw DBError.setDocumentError(message: "Article document를 추가하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Read
    func readItem(itemID: String) async throws -> Article {
        guard let article = try? await articleDB.document(itemID).getDocument(as: Article.self)
        else {
            throw DBError.getDocumentError(message: "ID가 일치하는 Article document를 읽어오는데 실패했습니다.")
        }
        
        return article
    }
    
    func readRecentItem(category: ANBDCategory) async throws -> Article {
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
        
    func readItemList(limit: Int) async throws -> [Article] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = articleDB
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = articleDB
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        let articleList = try await requestQuery
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: Article.self) }
        return articleList
    }
    
    func readItemList(writerID: String, limit: Int) async throws -> [Article] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = articleDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = articleDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.writerIDQuery = next
        }
        
        let articleList = try await requestQuery
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: Article.self) }
        return articleList
    }
    
    func readItemList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw NSError(domain: "Article Category Error", code: 4011)
        }
        
        var requestQuery: Query = articleDB
            .whereField("category", isEqualTo: category.rawValue)
        
        if let orderQuery {
            requestQuery = orderQuery
        } else {
            requestQuery = switch order {
            case .latest:
                requestQuery
                    .order(by: "createdAt", descending: true)
                    .limit(to: limit)
            case .mostLike:
                requestQuery
                    .order(by: "likeCount", descending: true)
                    .order(by: "createdAt", descending: true)
                    .limit(to: limit)
            case .mostComment:
                requestQuery
                    .order(by: "commentCount", descending: true)
                    .order(by: "createdAt", descending: true)
                    .limit(to: limit)
            }
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = requestQuery.start(afterDocument: lastSnapshot)
            orderQuery = next
        }
        
        let articleList = try await requestQuery
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: Article.self) }
        return articleList
    }
    
    func readItemList(keyword: String, limit: Int) async throws -> [Article] {
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
            .limit(to: limit)
        
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
        
        let articleList = try await requestQuery
            .getDocuments()
            .documents
            .compactMap { try? $0.data(as: Article.self) }
        return articleList
    }
    
    func refreshAll(limit: Int) async throws -> [Article] {
        allQuery = nil
        return try await readItemList(limit: limit)
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Article] {
        writerIDQuery = nil
        return try await readItemList(writerID: writerID, limit: limit)
    }
    
    func refreshOrder(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw NSError(domain: "Article Category Error", code: 4011)
        }
        
        orderQuery = nil
        return try await readItemList(category: category, by: order, limit: limit)
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Article] {
        guard !keyword.isEmpty else { return [] }
        searchQuery = nil
        return try await readItemList(keyword: keyword, limit: limit)
    }
    
    
    // MARK: Update
    func updateItem(item: Article) async throws {
        guard let _ = try? await articleDB.document(item.id).updateData([
            "category": item.category.rawValue,
            "title": item.title,
            "content": item.content,
            "thumbnailImagePath": item.thumbnailImagePath,
            "imagePaths": item.imagePaths,
            "likeCount": item.likeCount,
            "commentCount": item.commentCount
        ])
        else {
            throw DBError.updateDocumentError(message: "Article document를 업데이트하는데 실패했습니다.")
        }
    }
    
    // MARK: Delete
    func deleteItem(itemID: String) async throws {
        guard let _ = try? await articleDB.document(itemID).delete()
        else {
            throw DBError.deleteDocumentError(message: "ID가 일치하는 Article document를 삭제하는데 실패했습니다.")
        }
    }
    
    func resetSearchQuery() {
        searchQuery = nil
    }
    
}
