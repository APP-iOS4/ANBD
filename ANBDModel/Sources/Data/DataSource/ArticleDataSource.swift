//
//  ArticleDataSource.swift
//
//
//  Created by 유지호 on 4/13/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
extension Postable where Item == Article {
    
    func readRecentItem(category: ANBDCategory) async throws -> Article {
        let query = database
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
        
        guard let article = try? await query
            .getDocuments()
            .documents
            .first?
            .data(as: Item.self)
        else {
            throw DBError.getArticleDocumentError
        }
        
        return article
    }
    
    func readItemList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        var requestQuery: Query = database
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
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = requestQuery.start(afterDocument: lastSnapshot)
            orderQuery = next
        }
        
        guard let snapshot = try? await requestQuery.getDocuments().documents
        else {
            throw DBError.getArticleDocumentError
        }
        
        let articleList = snapshot.compactMap { try? $0.data(as: Item.self) }
        return articleList
    }
    
    func readItemList(keyword: String, limit: Int) async throws -> [Article] {
        var requestQuery: Query
        let filteredQuery = database
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
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = filteredQuery
                .start(afterDocument: lastSnapshot)
            
            searchQuery = next
        }
        
        guard let snapshot = try? await requestQuery.getDocuments().documents
        else {
            throw DBError.getArticleDocumentError
        }
        
        let articleList = snapshot.compactMap { try? $0.data(as: Item.self) }
        return articleList
    }
    
    func refreshOrder(
        category: ANBDCategory,
        by order: ArticleOrder,
        limit: Int
    ) async throws -> [Article] {
        orderQuery = nil
        return try await readItemList(category: category, by: order, limit: limit)
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Article] {
        searchQuery = nil
        return try await readItemList(keyword: keyword, limit: limit)
    }
    
    
    // MARK: Update
    func updateItem(item: Article) async throws {
        guard let _ = try? await database.document(item.id).updateData([
            "category": item.category.rawValue,
            "title": item.title,
            "content": item.content,
            "thumbnailImagePath": item.thumbnailImagePath,
            "imagePaths": item.imagePaths,
            "likeCount": item.likeCount,
            "commentCount": item.commentCount
        ])
        else {
            throw DBError.updateArticleDocumentError
        }
    }
    
}
