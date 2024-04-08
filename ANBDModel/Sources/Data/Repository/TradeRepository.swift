//
//  DefaultTradeRepository.swift
//
//
//  Created by 유지호 on 4/6/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
final class DefaultTradeRepository: TradeRepository {
    
    let tradeDB = Firestore.firestore().collection("TradeBoard")
    
    private var allQuery: Query?
    private var writerIDQuery: Query?
    private var searchQuery: Query?
    
    init() { }
    
    
    // MARK: Create
    func createTrade(trade: Trade) async throws {
        if trade.category == .nanua {
            guard let _ = try? await tradeDB.document(trade.id).setData([
                "id": trade.id,
                "writerID": trade.writerID,
                "writerNickname": trade.writerNickname,
                "createdAt": trade.createdAt,
                "category": trade.category.rawValue,
                "itemCategory": trade.itemCategory.description,
                "location": trade.location.rawValue,
                "tradeState": trade.tradeState.rawValue,
                "title": trade.title,
                "content": trade.content,
                "myProduct": trade.myProduct,
                "imagePaths": trade.imagePaths
            ])
            else {
                throw DBError.setDocumentError(message: "Trade document를 추가하는데 실패했습니다.")
            }
        } else {
            guard let _ = try? await tradeDB.document(trade.id).setData([
                "id": trade.id,
                "writerID": trade.writerID,
                "writerNickname": trade.writerNickname,
                "createdAt": trade.createdAt,
                "category": trade.category.rawValue,
                "itemCategory": trade.itemCategory.description,
                "location": trade.location.rawValue,
                "tradeState": trade.tradeState.rawValue,
                "title": trade.title,
                "content": trade.content,
                "myProduct": trade.myProduct,
                "wantProduct": trade.wantProduct ?? "",
                "imagePaths": trade.imagePaths
            ])
            else {
                throw DBError.setDocumentError(message: "Trade document를 추가하는데 실패했습니다.")
            }
        }
    }
    
    
    // MARK: Read
    func readTrade(tradeID: String) async throws -> Trade {
        guard let trade = try? await tradeDB.document(tradeID).getDocument(as: Trade.self)
        else {
            throw DBError.getDocumentError(message: "ID가 일치하는 Trade document를 읽어오는데 실패했습니다.")
        }
        
        return trade
    }
    
    func readTradeList() async throws -> [Trade] {
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = tradeDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = tradeDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Trade.self) }
    }
    
    func readTradeList(writerID: String) async throws -> [Trade] {
        var requestQuery: Query
        
        if let writerIDQuery {
            requestQuery = writerIDQuery
        } else {
            requestQuery = tradeDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
            
            guard let lastSnapshot = try await requestQuery.getDocuments().documents.last else {
                print("end")
                return []
            }
            
            let next = tradeDB
                .whereField("writerID", isEqualTo: writerID)
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
                .start(afterDocument: lastSnapshot)
            
            self.allQuery = next
        }
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Trade.self) }
    }
    
    func readTradeList(keyword: String) async throws -> [Trade] {
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
        
        return try await requestQuery.getDocuments().documents.compactMap { try $0.data(as: Trade.self) }
    }
    
    func refreshAll() async throws -> [Trade] {
        allQuery = nil
        return try await readTradeList()
    }
    
    func refreshWriterID(writerID: String) async throws -> [Trade] {
        writerIDQuery = nil
        return try await readTradeList(writerID: writerID)
    }
    
    func refreshSearch(keyword: String) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        searchQuery = nil
        return try await readTradeList(keyword: keyword)
    }
    
    
    // MARK: Update
    func updateTrade(trade: Trade) async throws {
        guard let _ = try? tradeDB.document(trade.id).setData(from: trade)
        else {
            throw DBError.updateDocumentError(message: "Trade document를 업데이트하는데 실패했습니다.")
        }
    }
    
    func updateTrade(tradeID: String, tradeState: TradeState) async throws {
        guard let _ = try? await tradeDB.document(tradeID).updateData([
            "tradeState": tradeState.rawValue
        ])
        else {
            throw DBError.updateDocumentError(message: "Trade document를 업데이트하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Delete
    func deleteTrade(tradeID: String) async throws {
        guard let _ = try? await tradeDB.document(tradeID).delete()
        else {
            throw DBError.deleteDocumentError(message: "ID가 일치하는 Trade document를 삭제하는데 실패했습니다.")
        }
    }
    
    func resetQuery() {
        allQuery = nil
        writerIDQuery = nil
        searchQuery = nil
    }
    
}
