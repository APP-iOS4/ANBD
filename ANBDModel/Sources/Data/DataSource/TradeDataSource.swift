//
//  TradeDataSource.swift
//
//
//  Created by 유지호 on 4/14/24.
//

import Foundation
import FirebaseFirestore

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
