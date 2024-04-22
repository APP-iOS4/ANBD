//
//  TradeRepository.swift
//  
//
//  Created by 유지호 on 4/7/24.
//

import Foundation

@available(iOS 15, *)
public protocol TradeRepository {
    // MARK: Create
    func createTrade(trade: Trade, imageDatas: [Data]) async throws
    
    // MARK: Read
    func readTrade(tradeID: String) async throws -> Trade
    func readTradeList(limit: Int) async throws -> [Trade]
    func readTradeList(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Trade]
    func readTradeList(category: ANBDCategory,
                       location: [Location]?,
                       itemCategory: [ItemCategory]?,
                       limit: Int) async throws -> [Trade]
    func readTradeList(keyword: String, limit: Int) async throws -> [Trade]
    func readRecentTradeList(category: ANBDCategory) async throws -> [Trade]
    func readAllTradeList(writerID: String) async throws -> [Trade]
    func refreshAll(limit: Int) async throws -> [Trade]
    func refreshWriterID(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Trade]
    func refreshFilter(category: ANBDCategory,
                       location: [Location]?,
                       itemCategory: [ItemCategory]?,
                       limit: Int) async throws -> [Trade]
    func refreshSearch(keyword: String, limit: Int) async throws -> [Trade]
    
    // MARK: Update
    func updateTrade(trade: Trade, imageDatas: [Data]) async throws
    func updateTrade(tradeID: String, tradeState: TradeState) async throws
    func likeTrade(tradeID: String) async throws
    
    // MARK: Delete
    func deleteTrade(trade: Trade) async throws
    func resetQuery()
}
