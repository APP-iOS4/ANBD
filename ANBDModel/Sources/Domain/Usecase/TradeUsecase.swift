//
//  TradeUsecase.swift
//
//
//  Created by 유지호 on 4/7/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
public protocol TradeUsecase {
    func writeTrade(trade: Trade, imageDatas: [Data]) async throws
    func loadTrade(tradeID: String) async throws -> Trade
    func loadTradeList() async throws -> [Trade]
    func loadTradeList(category: ANBDCategory) async throws -> [Trade]
    func loadTradeList(tradeState: TradeState) async throws -> [Trade]
    func loadTradeList(writerID: String) async throws -> [Trade]
    func refreshAllTradeList() async throws -> [Trade]
    func refreshCategoryTradeList(category: ANBDCategory) async throws -> [Trade]
    func refreshStateTradeList(tradeState: TradeState) async throws -> [Trade]
    func refreshWriterIDTradeList(writerID: String) async throws -> [Trade]
    func updateTrade(trade: Trade, imageDatas: [Data]) async throws
    func updateTradeState(tradeID: String, tradeState: TradeState) async throws
    func likeTrade(tradeID: String) async throws
    func deleteTrade(trade: Trade) async throws
}

@available(iOS 15, *)
public struct DefaultTradeUsecase: TradeUsecase {
    
    let userRepository: UserRepository = DefaultUserRepository()
    let tradeRepository: TradeRepository = DefaultTradeRepository()
    
    let storage = StorageManager.shared
    
    public init() { }
    
    
    /// Trade를 작성하는 메서드
    ///  - Parameters:
    ///    - trade: 작성한 Trade
    ///    - imageDatas: 저장할 사진 Data 배열
    public func writeTrade(trade: Trade, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.uploadImageList(
            path: .trade,
            containerID: trade.id,
            imageDatas: imageDatas
        )
        var newTrade = trade
        newTrade.imagePaths = imagePaths
        
        try await tradeRepository.createTrade(trade: newTrade)
    }
    
    
    /// 특정 ID의 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - tradeID: 불러올 Trade의 ID
    /// - Returns: tradeID가 일치하는 Trade
    public func loadTrade(tradeID: String) async throws -> Trade {
        try await tradeRepository.readTrade(tradeID: tradeID)
    }
    
    
    /// 모든 Trade를 불러오는 메서드
    /// - Returns: 모든 Trade 배열
    public func loadTradeList() async throws -> [Trade] {
        try await tradeRepository.readTradeList()
    }
    
    
    /// 카테고리가 일치하는 모든 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - category: Trade의 카테고리 (나눠쓰기, 바꿔쓰기)
    /// - Returns: 카테고리가 일치하는 Trade 배열
    public func loadTradeList(category: ANBDCategory) async throws -> [Trade] {
        try await tradeRepository.readTradeList(category: category)
    }
    
    
    /// 거래상태가 일치하는 모든 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - tradeState: Trade의 상태 (거래중, 거래완료)
    /// - Returns: 거래상태가 일치하는 Trade 배열
    public func loadTradeList(tradeState: TradeState) async throws -> [Trade] {
        try await tradeRepository.readTradeList(tradeState: tradeState)
    }
    
    
    /// 작성자 ID가 일치하는 모든 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 작성자의 ID
    /// - Returns: 작성자 ID가 일치하는 Trade 배열
    public func loadTradeList(writerID: String) async throws -> [Trade] {
        try await tradeRepository.readTradeList(writerID: writerID)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 최신 Trade 목록 10개를 반환하는 메서드
    ///  - Returns: Trade 배열
    public func refreshAllTradeList() async throws -> [Trade] {
        try await tradeRepository.refreshAll()
    }
    
    
    /// 페이지네이션 Query를 초기화하고 카테고리가 일치하는 최신 Trade 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 Trade의 카테고리
    /// - Returns: 카테고리가 일치하는 Trade 배열
    public func refreshCategoryTradeList(category: ANBDCategory) async throws -> [Trade] {
        try await tradeRepository.refreshCategory(category: category)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 거래상태가 일치하는 최신 Trade 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - tradeState: 불러올 Trade의 거래상태
    /// - Returns: 거래상태가 일치하는 Trade 배열
    public func refreshStateTradeList(tradeState: TradeState) async throws -> [Trade] {
        try await tradeRepository.refreshCategory(tradeState: tradeState)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 작성자 ID가 일치하는 최신 Trade 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Trade의 writerID
    /// - Returns: writerID가 일치하는 Trade 배열
    public func refreshWriterIDTradeList(writerID: String) async throws -> [Trade] {
        try await tradeRepository.refreshWriterID(writerID: writerID)
    }
    
    
    /// Trade의 정보를 수정하는 메서드
    /// - Parameters:
    ///   - category: 수정한 Trade의 카테고리
    ///   - trade: 수정한 Trade 정보
    ///   - imageDatas: 수정한 Trade의 이미지 Data 배열
    public func updateTrade(trade: Trade, imageDatas: [Data]) async throws {
        if trade.category == .baccua && trade.wantProduct == nil {
            throw NSError(domain: "Trade Field Error", code: 4010)
        }
        
        let imagePaths = try await storage.updateImageList(path: .trade, containerID: trade.id, imagePaths: trade.imagePaths, imageDatas: imageDatas)
        var updatedTrade = trade
        updatedTrade.imagePaths = imagePaths
        
        try await tradeRepository.updateTrade(trade: updatedTrade)
    }
    
    
    /// Trade의 거래 상태를 수정하는 메서드
    /// - Parameters:
    ///   - tradeID: 수정하려는 Trade의 ID
    ///   - tradeState: 변경하려는 거래 상태
    public func updateTradeState(tradeID: String, tradeState: TradeState) async throws {
        try await tradeRepository.updateTrade(tradeID: tradeID, tradeState: tradeState)
    }
    
    
    /// Trade를 찜하는 메서드
    /// - Parameters:
    ///   - tradeID: 찜할 Trade의 ID
    public func likeTrade(tradeID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        var userInfo = try await userRepository.readUserInfo(userID: userID)
        
        if userInfo.likeTrades.contains(tradeID) {
            userInfo.likeTrades = userInfo.likeTrades.filter { $0 != tradeID }
        } else {
            userInfo.likeTrades.append(tradeID)
        }
        
        try await userRepository.updateUserInfo(user: userInfo)
    }
    
    
    /// Trade를 삭제하는 메서드
    /// - Parameters:
    ///   - trade: 삭제하려는 trade의 정보
    public func deleteTrade(trade: Trade) async throws {
        try await storage.deleteImageList(path: .trade, containerID: trade.id, imagePaths: trade.imagePaths)
        try await tradeRepository.deleteTrade(tradeID: trade.id)
        try await userRepository.updateUserInfoList(tradeID: trade.id)
    }
    
}
