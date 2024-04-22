//
//  PostDataSource.swift
//
//
//  Created by 유지호 on 4/15/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
protocol Postable<Item>: AnyObject {
    associatedtype Item: Codable & Identifiable
    
    var database: CollectionReference { get }
    
    var allQuery: Query? { get set }
    var writerIDQuery: Query? { get set }
    var searchQuery: Query? { get set }
    var orderQuery: Query? { get set }
    var filterQuery: Query? { get set }
    
    func createItem(item: Item) async throws
    func readItem(itemID: String) async throws -> Item
    func readItemList(limit: Int) async throws -> [Item]
    func readItemList(writerID: String, limit: Int) async throws -> [Item]
    func refreshAll(limit: Int) async throws -> [Item]
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Item]
    func deleteItem(itemID: String) async throws
    func resetSearchQuery()
}


// MARK: PostDataSource
@available(iOS 15, *)
class PostDataSource<T: Codable & Identifiable>: Postable {
    
    typealias Item = T
    
    let database: CollectionReference
    
    var allQuery: Query?
    var writerIDQuery: Query?
    var searchQuery: Query?
    var orderQuery: Query?
    var filterQuery: Query?
    
    init(database: CollectionReference) {
        self.database = database
        
        #if DEBUG
        print("\(T.self) DataSource init")
        #endif
    }
    
    deinit {
        #if DEBUG
        print("\(T.self) DataSource deinit")
        #endif
    }
    
    
    func createItem(item: T) async throws {
        guard let _ = try? database.document("\(item.id)").setData(from: item)
        else {
            throw DBError.setDocumentError
        }
    }
    
    func readItem(itemID: String) async throws -> T {
        guard let item = try? await database
            .document(itemID)
            .getDocument()
            .data(as: T.self)
        else {
            throw DBError.getDocumentError
        }
        
        return item
    }
    
    func readItemList(limit: Int) async throws -> [T] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = database
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = database
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError
        }
        
        let itemList = snapshot.compactMap { try? $0.data(as: T.self) }
        return itemList
    }
    
    func readItemList(writerID: String, limit: Int) async throws -> [T] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = database
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = database
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.writerIDQuery = next
        }
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError
        }
        
        let itemList = snapshot.compactMap { try? $0.data(as: T.self) }
        return itemList
    }
    
    func refreshAll(limit: Int) async throws -> [T] {
        allQuery = nil
        return try await readItemList(limit: limit)
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [T] {
        writerIDQuery = nil
        return try await readItemList(writerID: writerID, limit: limit)
    }
    
//    func updateItem(item: T) async throws { }
    
    func deleteItem(itemID: String) async throws {
        guard let _ = try? await database.document(itemID).delete()
        else {
            throw DBError.deleteDocumentError
        }
    }
    
    func resetSearchQuery() {
        searchQuery = nil
    }
    
}


// MARK: Postable - Article
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


// MARK: Postable - Comment
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


// MARK: Postable - Trade
@available(iOS 15.0, *)
extension Postable where Item == Trade {
    
    func readItemList(
        category: ANBDCategory,
        location: [Location]?,
        itemCategory: [ItemCategory]?,
        limit: Int
    ) async throws -> [Trade] {
        var requestQuery: Query
        var query = database
            .whereField("category", isEqualTo: category.rawValue)
        
        if let location, let itemCategory {
            query = query.whereFilter(
                .andFilter([
                    .whereField("location", in: location.map { $0.rawValue }),
                    .whereField("itemCategory", in: itemCategory.map { $0.rawValue })
                ])
            )
        } else if let location {
            query = database
                .whereField("location", in: location.map { $0.rawValue })
        } else if let itemCategory {
            query = database
                .whereField("itemCategory", in: itemCategory.map { $0.rawValue })
        }
        
        query = query
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        if let filterQuery {
            requestQuery = filterQuery
        } else {
            requestQuery = query
            
            guard let lastSnapshot = try await requestQuery
                .getDocuments()
                .documents
                .last
            else {
                print("end")
                return []
            }
            
            let next = query.start(afterDocument: lastSnapshot)
            
            filterQuery = next
        }
        
        guard let snapshot = try? await requestQuery.getDocuments().documents
        else {
            throw DBError.getTradeDocumentError
        }
        
        let tradeList = snapshot.compactMap { try? $0.data(as: Trade.self) }
        return tradeList
    }
    
    func readItemList(keyword: String, limit: Int) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        
        var requestQuery: Query
        let filteredQuery = database
            .whereFilter(
                .orFilter([
                    .whereField("itemCategory", isEqualTo: keyword),
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
        
        guard let snapshot = try? await requestQuery
            .getDocuments()
            .documents
        else {
            throw DBError.getTradeDocumentError
        }
        
        let tradeList = snapshot.compactMap { try? $0.data(as: Trade.self) }
        return tradeList
    }
    
    func readRecentItemList(category: ANBDCategory) async throws -> [Trade] {
        let query = database
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .limit(to: category == .nanua ? 4 : 2)
        
        guard let snapshot = try? await query
            .getDocuments()
            .documents
        else {
            throw DBError.getTradeDocumentError
        }
                
        let tradeList = snapshot.compactMap { try? $0.data(as: Trade.self) }
        return tradeList
    }
    
    func refreshFilter(
        category: ANBDCategory,
        location: [Location]?,
        itemCategory: [ItemCategory]?,
        limit: Int
    ) async throws -> [Trade] {
        filterQuery = nil
        
        return try await readItemList(
            category: category,
            location: location,
            itemCategory: itemCategory,
            limit: limit
        )
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        searchQuery = nil
        return try await readItemList(keyword: keyword, limit: limit)
    }
    
    
    // MARK: Update
    func updateItem(item: Trade) async throws {
        guard let _ = try? database.document(item.id).setData(from: item)
        else {
            throw DBError.updateTradeDocumentError
        }
    }

    func updateItem(tradeID: String, tradeState: TradeState) async throws {
        guard let _ = try? await database.document(tradeID).updateData([
            "tradeState": tradeState.rawValue
        ])
        else {
            throw DBError.updateTradeDocumentError
        }
    }
    
}
