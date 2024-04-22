//
//  DefaultTradeRepository.swift
//
//
//  Created by 유지호 on 4/6/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
struct TradeRepositoryImpl: TradeRepository {
    
    private let tradeDataSource: any Postable<Trade>
    private let userDataSource: UserDataSource
    
    private let storage = StorageManager.shared
    
    init(
        tradeDataSource: any Postable<Trade> = PostDataSource<Trade>(database: .tradeDatabase),
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
        newTrade.thumbnailImagePath = imagePaths.first ?? ""
        
        if !imagePaths.isEmpty {
            newTrade.imagePaths = Array(imagePaths[1...])
        }
        
        try await tradeDataSource.createItem(item: newTrade)
    }
    
    
    // MARK: Read
    func readTrade(tradeID: String) async throws -> Trade {
        let trade = try await tradeDataSource.readItem(itemID: tradeID)
        return trade
    }
    
    func readTradeList(limit: Int) async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readItemList(limit: limit)
        return tradeList
    }
    
    func readTradeList(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readItemList(writerID: writerID, category: category, limit: limit)
        return tradeList
    }
    
    func readTradeList(
        category: ANBDCategory,
        location: [Location]?,
        itemCategory: [ItemCategory]?,
        limit: Int
    ) async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readItemList(
            category: category,
            location: location,
            itemCategory: itemCategory,
            limit: limit
        )
        return tradeList
    }
    
    func readTradeList(keyword: String, limit: Int) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        
        let tradeList = try await tradeDataSource.readItemList(keyword: keyword, limit: limit)
        return tradeList
    }
    
    func readRecentTradeList(category: ANBDCategory) async throws -> [Trade] {
        let tradeList = try await tradeDataSource.readRecentItemList(category: category)
        return tradeList
    }
    
    func refreshAll(limit: Int) async throws -> [Trade] {
        let refreshedList = try await tradeDataSource.refreshAll(limit: limit)
        return refreshedList
    }
    
    func refreshWriterID(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Trade] {
        let refreshedList = try await tradeDataSource.refreshWriterID(writerID: writerID, category: category, limit: limit)
        return refreshedList
    }
    
    func refreshFilter(
        category: ANBDCategory,
        location: [Location]?,
        itemCategory: [ItemCategory]?,
        limit: Int
    ) async throws -> [Trade] {
        let refreshedList = try await tradeDataSource.readItemList(
            category: category,
            location: location,
            itemCategory: itemCategory,
            limit: limit
        )
        return refreshedList
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Trade] {
        guard !keyword.isEmpty else { return [] }
        
        let refreshedList = try await tradeDataSource.refreshSearch(keyword: keyword, limit: limit)
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
        updatedTrade.thumbnailImagePath = imagePaths.first ?? ""
        
        if !imagePaths.isEmpty {
            updatedTrade.imagePaths = Array(imagePaths[1...])
        }
        
        try await tradeDataSource.updateItem(item: updatedTrade)
    }
    
    func updateTrade(tradeID: String, tradeState: TradeState) async throws {
        try await tradeDataSource.updateItem(tradeID: tradeID, tradeState: tradeState)
    }
    
    func likeTrade(tradeID: String) async throws {
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
        if !trade.thumbnailImagePath.isEmpty {
            try await storage.deleteImage(
                path: .trade,
                containerID: "\(trade.id)/thumbnail",
                imagePath: trade.thumbnailImagePath
            )
        }
        
        try await storage.deleteImageList(
            path: .trade,
            containerID: trade.id,
            imagePaths: trade.imagePaths
        )
        try await tradeDataSource.deleteItem(itemID: trade.id)
        try await userDataSource.updateUserInfoList(tradeID: trade.id)
    }
    
    func resetQuery() {
        tradeDataSource.resetSearchQuery()
    }
    
}
