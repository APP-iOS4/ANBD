//
//  DefaultTradeRepository.swift
//
//
//  Created by 유지호 on 4/6/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
final class DefaultTradeRepository: TradeRepository {
    
    private let tradeDataSource: TradeDataSource
    private let userDataSource: UserDataSource
    
    private let storage = StorageManager.shared
    
    init(
        tradeDataSource: TradeDataSource = DefaultTradeDataSource(),
        userDataSource: UserDataSource = DefaultUserDataSource()
    ) {
        self.tradeDataSource = tradeDataSource
        self.userDataSource = userDataSource
    }
    
    
    // MARK: Create
    func createTrade(trade: Trade, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.uploadImageList(
            path: .trade,
            containerID: trade.id,
            imageDatas: imageDatas
        )
        var newTrade = trade
        newTrade.imagePaths = imagePaths
        
        try await tradeDataSource.createTrade(trade: newTrade)
    }
    
    
    // MARK: Read
    func readTrade(tradeID: String) async throws -> Trade {
        let trade = try await tradeDataSource.readTrade(tradeID: tradeID)
        return trade
    }
    
    func readTradeList() async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readTradeList()
        return tradeList
    }
    
    func readTradeList(writerID: String) async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readTradeList(writerID: writerID)
        return tradeList
    }
    
    func readTradeList(
        category: ANBDCategory,
        location: Location?,
        itemCategory: ItemCategory?
    ) async throws -> [Trade] {
        guard category == .nanua || category == .baccua else {
            throw NSError(domain: "Recent Trade Category Error", code: 4012)
        }
        
        let tradeList = try await tradeDataSource.readTradeList(
            category: category,
            location: location,
            itemCategory: itemCategory
        )
        return tradeList
    }
    
    func readTradeList(keyword: String) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        
        let tradeList = try await tradeDataSource.readTradeList(keyword: keyword)
        return tradeList
    }
    
    func readRecentTradeList(category: ANBDCategory) async throws -> [Trade] {
        guard category == .nanua || category == .baccua else {
            throw NSError(domain: "Recent Trade Category Error", code: 4012)
        }
        
        let tradeList = try await tradeDataSource.readRecentTradeList(category: category)
        return tradeList
    }
    
    func refreshAll() async throws -> [Trade] {
        let refreshedList = try await tradeDataSource.refreshAll()
        return refreshedList
    }
    
    func refreshWriterID(writerID: String) async throws -> [Trade] {
        let refreshedList = try await tradeDataSource.refreshWriterID(writerID: writerID)
        return refreshedList
    }
    
    func refreshFilter(
        category: ANBDCategory,
        location: Location?,
        itemCategory: ItemCategory?
    ) async throws -> [Trade] {
        guard category == .nanua || category == .baccua else {
            throw NSError(domain: "Recent Trade Category Error", code: 4012)
        }
        
        let refreshedList = try await tradeDataSource.readTradeList(
            category: category,
            location: location,
            itemCategory: itemCategory
        )
        return refreshedList
    }
    
    func refreshSearch(keyword: String) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        
        let refreshedList = try await tradeDataSource.refreshSearch(keyword: keyword)
        return refreshedList
    }
    
    
    // MARK: Update
    func updateTrade(trade: Trade, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.updateImageList(
            path: .trade,
            containerID: trade.id,
            imagePaths: trade.imagePaths,
            imageDatas: imageDatas
        )
        var updatedTrade = trade
        updatedTrade.imagePaths = imagePaths
        
        try await tradeDataSource.updateTrade(trade: updatedTrade)
    }
    
    func updateTrade(tradeID: String, tradeState: TradeState) async throws {
        try await tradeDataSource.updateTrade(tradeID: tradeID, tradeState: tradeState)
    }
    
    public func likeTrade(tradeID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        var userInfo = try await userDataSource.readUserInfo(userID: userID)
        
        if userInfo.likeTrades.contains(tradeID) {
            userInfo.likeTrades = userInfo.likeTrades.filter { $0 != tradeID }
        } else {
            userInfo.likeTrades.append(tradeID)
        }
        
        try await userDataSource.updateUserInfo(user: userInfo)
    }
    
    
    // MARK: Delete
    func deleteTrade(trade: Trade) async throws {
        try await storage.deleteImageList(
            path: .trade,
            containerID: trade.id,
            imagePaths: trade.imagePaths
        )
        try await tradeDataSource.deleteTrade(tradeID: trade.id)
        try await userDataSource.updateUserInfoList(tradeID: trade.id)
    }
    
    func resetQuery() {
        tradeDataSource.resetQuery()
    }
    
}
