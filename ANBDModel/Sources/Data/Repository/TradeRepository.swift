//
//  DefaultTradeRepository.swift
//
//
//  Created by 유지호 on 4/6/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15, *)
struct DefaultTradeRepository {
    
    let tradeDB = Firestore.firestore().collection("TradeBoard")
    
    init() { }
    
    
    // MARK: Create
    func createTrade(trade: Trade) async throws {
        guard let _ = try? tradeDB.document(trade.id).setData(from: trade)
        else {
            throw DBError.setDocumentError(message: "Trade document를 추가하는데 실패했습니다.")
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
        guard let snapshot = try? await tradeDB
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError(message: "Trade documents를 읽어오는데 실패했습니다.")
        }
        
        return snapshot.compactMap { try? $0.data(as: Trade.self) }
    }
    
    func readTradeList(category: TradeCategory) async throws -> [Trade] {
        guard let snapshot = try? await tradeDB
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError(message: "Trade documents를 읽어오는데 실패했습니다.")
        }
        
        return snapshot.compactMap { try? $0.data(as: Trade.self) }
    }
    
    func readTradeList(writerID: String) async throws -> [Trade] {
        guard let snapshot = try? await tradeDB
            .whereField("writerID", isEqualTo: writerID)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getDocumentError(message: "Trade documents를 읽어오는데 실패했습니다.")
        }
        
        return snapshot.compactMap { try? $0.data(as: Trade.self) }
    }
    
    
    // MARK: Update
    func updateTrade(category: TradeCategory, trade: Trade) async throws {
        switch category {
        case .nanua:
            guard let myProduct = trade.myProduct else { return }
            guard let _ = try? await tradeDB.document(trade.id).updateData([
                "category": trade.category.rawValue,
                "title": trade.title,
                "content": trade.content,
                "myProduct": myProduct,
                "imagePaths": trade.imagePaths
            ])
            else {
                throw DBError.updateDocumentError(message: "Trade document를 업데이트하는데 실패했습니다.")
            }
        case .baccua:
            guard let myProduct = trade.myProduct,
                  let wantProduct = trade.wantProduct
            else { return }
            guard let _ = try? await tradeDB.document(trade.id).updateData([
                "category": trade.category.rawValue,
                "title": trade.title,
                "content": trade.content,
                "myProduct": myProduct,
                "wantProduct": wantProduct,
                "imagePaths": trade.imagePaths
            ])
            else {
                throw DBError.updateDocumentError(message: "Trade document를 업데이트하는데 실패했습니다.")
            }
        }
    }
    
    func updateTrade(to category: TradeCategory, trade: Trade) async throws {
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
    
}
