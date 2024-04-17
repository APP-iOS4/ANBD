//
//  TradeDataSource.swift
//
//
//  Created by 유지호 on 4/14/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15.0, *)
protocol TradeDataSource: Postable where Item == Trade {
    func readItemList(category: ANBDCategory,
                      location: [Location]?,
                      itemCategory: [ItemCategory]?,
                      limit: Int) async throws -> [Trade]
    func readRecentItemList(category: ANBDCategory) async throws -> [Trade]
    func refreshFilter(category: ANBDCategory,
                       location: [Location]?,
                       itemCategory: [ItemCategory]?,
                       limit: Int) async throws -> [Trade]
    func updateItem(tradeID: String, tradeState: TradeState) async throws
}

@available(iOS 15.0, *)
final class DefaultTradeDataSource: TradeDataSource {
    
    private let tradeDB = Firestore.firestore().collection("TradeBoard")
    
    private var allQuery: Query?
    private var writerIDQuery: Query?
    private var filterQuery: Query?
    private var searchQuery: Query?
    
    init() { }
    
    
    // MARK: Create
    func createItem(item: Trade) async throws {
        if item.category == .nanua {
            guard let _ = try? await tradeDB.document(item.id).setData([
                "id": item.id,
                "writerID": item.writerID,
                "writerNickname": item.writerNickname,
                "createdAt": item.createdAt,
                "category": item.category.rawValue,
                "itemCategory": item.itemCategory.rawValue,
                "location": item.location.rawValue,
                "tradeState": item.tradeState.rawValue,
                "title": item.title,
                "content": item.content,
                "myProduct": item.myProduct,
                "thumbnailImagePath": item.thumbnailImagePath,
                "imagePaths": item.imagePaths
            ])
            else {
                throw DBError.setTradeDocumentError
            }
        } else {
            guard let _ = try? await tradeDB.document(item.id).setData([
                "id": item.id,
                "writerID": item.writerID,
                "writerNickname": item.writerNickname,
                "createdAt": item.createdAt,
                "category": item.category.rawValue,
                "itemCategory": item.itemCategory.rawValue,
                "location": item.location.rawValue,
                "tradeState": item.tradeState.rawValue,
                "title": item.title,
                "content": item.content,
                "myProduct": item.myProduct,
                "wantProduct": item.wantProduct ?? "",
                "thumbnailImagePath": item.thumbnailImagePath,
                "imagePaths": item.imagePaths
            ])
            else {
                throw DBError.setTradeDocumentError
            }
        }
    }
    
    
    // MARK: Read
    func readItem(itemID: String) async throws -> Trade {
        guard let trade = try? await tradeDB.document(itemID).getDocument(as: Trade.self)
        else {
            throw DBError.getTradeDocumentError
        }
        
        return trade
    }
    
    func readItemList(limit: Int) async throws -> [Trade] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = tradeDB
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
            
            let next = tradeDB
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
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
    
    func readItemList(writerID: String, limit: Int) async throws -> [Trade] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = tradeDB
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
            
            let next = tradeDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
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
    
    func readItemList(
        category: ANBDCategory,
        location: [Location]?,
        itemCategory: [ItemCategory]?,
        limit: Int
    ) async throws -> [Trade] {
        var requestQuery: Query
        var query = tradeDB
            .whereField("category", isEqualTo: category.rawValue)
        
        if let location, let itemCategory {
            query = query.whereFilter(
                .andFilter([
                    .whereField("location", in: location.map { $0.rawValue }),
                    .whereField("itemCategory", in: itemCategory.map { $0.rawValue })
                ])
            )
        } else if let location {
            query = tradeDB
                .whereField("location", in: location.map { $0.rawValue })
        } else if let itemCategory {
            query = tradeDB
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
        let filteredQuery = tradeDB
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
        let query = tradeDB
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
    
    func refreshAll(limit: Int) async throws -> [Trade] {
        allQuery = nil
        return try await readItemList(limit: limit)
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Trade] {
        writerIDQuery = nil
        return try await readItemList(writerID: writerID, limit: limit)
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
        guard let _ = try? tradeDB.document(item.id).setData(from: item)
        else {
            throw DBError.updateTradeDocumentError
        }
    }
    
    func updateItem(tradeID: String, tradeState: TradeState) async throws {
        guard let _ = try? await tradeDB.document(tradeID).updateData([
            "tradeState": tradeState.rawValue
        ])
        else {
            throw DBError.updateTradeDocumentError
        }
    }
    
    // MARK: Delete
    func deleteItem(itemID: String) async throws {
        guard let _ = try? await tradeDB.document(itemID).delete()
        else {
            throw DBError.deleteTradeDocumentError
        }
    }
    
    func resetSearchQuery() {
        searchQuery = nil
    }
    
}
