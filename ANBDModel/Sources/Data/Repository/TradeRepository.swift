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
    private var nanuaQuery: Query?
    private var baccuaQuery: Query?
    private var tradingQuery: Query?
    private var finishQuery: Query?
    private var writerIDQuery: Query?
    
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
        var requestQuery: Query
        
        if let allQuery {
            requestQuery = allQuery
        } else {
            requestQuery = tradeDB
                .order(by: "createdAt", descending: true)
                .limit(to: 10)
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "Trade documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.tradeDB
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                self?.allQuery = next
                
                let tradeList = snapshot.documents.compactMap { try? $0.data(as: Trade.self) }
                continuation.resume(returning: tradeList)
            }
        }
    }
    
    func readTradeList(category: ANBDCategory) async throws -> [Trade] {
        guard category == .nanua || category == .baccua else { return [] }
        
        var requestQuery: Query
        
        if category == .nanua, let nanuaQuery {
            requestQuery = nanuaQuery
        } else if category == .baccua, let baccuaQuery {
            requestQuery = baccuaQuery
        }
        
        requestQuery = tradeDB
            .whereField("category", isEqualTo: category)
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "category가 일치하는 Trade documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.tradeDB
                    .whereField("category", isEqualTo: category)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                if category == .nanua {
                    self?.nanuaQuery = next
                } else {
                    self?.baccuaQuery = next
                }
                    
                let tradeList = snapshot.documents.compactMap { try? $0.data(as: Trade.self) }
                continuation.resume(returning: tradeList)
            }
        }
    }
    
    func readTradeList(tradeState: TradeState) async throws -> [Trade] {
        var requestQuery: Query
        
        if tradeState == .trading, let tradingQuery {
            requestQuery = tradingQuery
        } else if tradeState == .finish, let finishQuery {
            requestQuery = finishQuery
        }
        
        requestQuery = tradeDB
            .whereField("tradeState", isEqualTo: tradeState)
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "tradeState가 일치하는 Article documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.tradeDB
                    .whereField("tradeState", isEqualTo: tradeState)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                if tradeState == .trading {
                    self?.tradingQuery = next
                } else {
                    self?.finishQuery = next
                }
                    
                let tradeList = snapshot.documents.compactMap { try? $0.data(as: Trade.self) }
                continuation.resume(returning: tradeList)
            }
        }
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
        }
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            requestQuery.addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    print(error.debugDescription)
                    continuation.resume(throwing: DBError.getDocumentError(message: "writerID가 일치하는 Trade documents를 읽어오는데 실패했습니다."))
                    return
                }
                
                guard let lastSnapshot = snapshot.documents.last else {
                    print("end")
                    return
                }
                
                let next = self?.tradeDB
                    .whereField("writerID", isEqualTo: writerID)
                    .order(by: "createdAt", descending: true)
                    .limit(to: 10)
                    .start(afterDocument: lastSnapshot)
                
                self?.writerIDQuery = next
                
                let tradeList = snapshot.documents.compactMap { try? $0.data(as: Trade.self) }
                continuation.resume(returning: tradeList)
            }
        }
    }
    
    func refreshAll() async throws -> [Trade] {
        allQuery = nil
        return try await readTradeList()
    }
    
    func refreshCategory(category: ANBDCategory) async throws -> [Trade] {
        guard category == .nanua || category == .baccua else { return [] }
        
        if category == .nanua {
            nanuaQuery = nil
        } else {
            baccuaQuery = nil
        }
        
        return try await readTradeList(category: category)
    }
    
    func refreshCategory(tradeState: TradeState) async throws -> [Trade] {
        if tradeState == .trading {
            tradingQuery = nil
        } else {
            finishQuery = nil
        }
        
        return try await readTradeList(tradeState: tradeState)
    }
    
    func refreshWriterID(writerID: String) async throws -> [Trade] {
        writerIDQuery = nil
        return try await readTradeList(writerID: writerID)
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
    
}
