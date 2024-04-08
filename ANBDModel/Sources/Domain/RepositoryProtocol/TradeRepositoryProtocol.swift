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
    func createTrade(trade: Trade) async throws
    
    // MARK: Read
    func readTrade(tradeID: String) async throws -> Trade
    func readTradeList() async throws -> [Trade]
    func readTradeList(category: ANBDCategory) async throws -> [Trade]
    func readTradeList(tradeState: TradeState) async throws -> [Trade]
    func readTradeList(writerID: String) async throws -> [Trade]
    
    // MARK: Update
    func updateTrade(trade: Trade) async throws
    func updateTrade(tradeID: String, tradeState: TradeState) async throws
    
    // MARK: Delete
    func deleteTrade(tradeID: String) async throws
}
