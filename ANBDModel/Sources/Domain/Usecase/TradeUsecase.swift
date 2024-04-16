//
//  TradeUsecase.swift
//
//
//  Created by 유지호 on 4/7/24.
//

import Foundation

@available(iOS 15, *)
public protocol TradeUsecase {
    func writeTrade(trade: Trade, imageDatas: [Data]) async throws
    func loadTrade(tradeID: String) async throws -> Trade
    func loadTradeList(limit: Int?) async throws -> [Trade]
    func loadTradeList(writerID: String, limit: Int?) async throws -> [Trade]
    func loadFilteredTradeList(category: ANBDCategory,
                               location: Location?,
                               itemCategory: ItemCategory?,
                               limit: Int?) async throws -> [Trade]
    func loadRecentTradeList(category: ANBDCategory) async throws -> [Trade]
    func searchTrade(keyword: String, limit: Int?) async throws -> [Trade]
    func refreshAllTradeList(limit: Int?) async throws -> [Trade]
    func refreshWriterIDTradeList(writerID: String, limit: Int?) async throws -> [Trade]
    func refreshFilteredTradeList(category: ANBDCategory,
                                  location: Location?,
                                  itemCategory: ItemCategory?,
                                  limit: Int?) async throws -> [Trade]
    func refreshSearchTradeList(keyword: String, limit: Int?) async throws -> [Trade]
    func updateTrade(trade: Trade, imageDatas: [Data]) async throws
    func updateTradeState(tradeID: String, tradeState: TradeState) async throws
    func likeTrade(tradeID: String) async throws
    func deleteTrade(trade: Trade) async throws
    func resetQuery()
}

@available(iOS 15, *)
public struct DefaultTradeUsecase: TradeUsecase {
    
    let tradeRepository: TradeRepository = DefaultTradeRepository()
    
    
    public init() { }
    
    
    /// Trade를 작성하는 메서드
    ///  - Parameters:
    ///    - trade: 작성한 Trade
    ///    - imageDatas: 저장할 사진 Data 배열
    public func writeTrade(trade: Trade, imageDatas: [Data]) async throws {
        try await tradeRepository.createTrade(trade: trade, imageDatas: imageDatas)
    }
    
    
    /// 특정 ID의 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - tradeID: 불러올 Trade의 ID
    /// - Returns: tradeID가 일치하는 Trade
    public func loadTrade(tradeID: String) async throws -> Trade {
        try await tradeRepository.readTrade(tradeID: tradeID)
    }
    
    
    /// 모든 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 모든 Trade 배열
    public func loadTradeList(limit: Int?) async throws -> [Trade] {
        try await tradeRepository.readTradeList(limit: limit ?? 10)
    }
    
    
    /// 작성자 ID가 일치하는 모든 Trade를 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 작성자의 ID
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 작성자 ID가 일치하는 Trade 배열
    public func loadTradeList(writerID: String, limit: Int?) async throws -> [Trade] {
        try await tradeRepository.readTradeList(writerID: writerID, limit: limit ?? 10)
    }
    
    
    /// 적용된 필터에 해당되는 Trade 배열을 불러오는 메서드
    /// - Parameters:
    ///   - category: Trade의 카테고리 (1: 나눠쓰기, 2: 바꿔쓰기)
    ///   - location: Trade의 설정된 지역
    ///   - itemCategory: Trade의 물건 카테고리
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 적용된 필터에 해당되는 Trade 배열
    public func loadFilteredTradeList(
        category: ANBDCategory,
        location: Location?,
        itemCategory: ItemCategory?,
        limit: Int?
    ) async throws -> [Trade] {
        try await tradeRepository.readTradeList(
            category: category,
            location: location,
            itemCategory: itemCategory,
            limit: limit ?? 10
        )
    }
    
    
    /// 카테고리가 일치하는 최신 Trade 배열을 불러오는 메서드
    /// - Parameters:
    ///   - category: Trade의 카테고리
    /// - Returns: 카테고리가 일치하는 최신 Trade 배열
    public func loadRecentTradeList(category: ANBDCategory) async throws -> [Trade] {
        try await tradeRepository.readRecentTradeList(category: category)
    }
    
    
    /// keyword로 Trade을 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 keyword
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: title, content, itemCategory가 keyword에 해당하는 Trade 배열
    public func searchTrade(keyword: String, limit: Int?) async throws -> [Trade] {
        try await tradeRepository.readTradeList(keyword: keyword, limit: limit ?? 10)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 최신 Trade 목록을 반환하는 메서드
    /// - Parameters:
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: Trade 배열
    public func refreshAllTradeList(limit: Int?) async throws -> [Trade] {
        try await tradeRepository.refreshAll(limit: limit ?? 10)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 작성자 ID가 일치하는 최신 Trade 목록을 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Trade의 writerID
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: writerID가 일치하는 Trade 배열
    public func refreshWriterIDTradeList(writerID: String, limit: Int?) async throws -> [Trade] {
        try await tradeRepository.refreshWriterID(writerID: writerID, limit: limit ?? 10)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 필터에 해당하는 Trade 목록을 불러오는 메서드
    /// - Parameters:
    ///   - category: Trade의 카테고리 (1: 나눠쓰기, 2: 바꿔쓰기)
    ///   - location: Trade의 설정된 지역
    ///   - itemCategory: Trade의 물건 카테고리
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 적용된 필터에 해당되는 Trade 배열
    public func refreshFilteredTradeList(
        category: ANBDCategory,
        location: Location?,
        itemCategory: ItemCategory?,
        limit: Int?
    ) async throws -> [Trade] {
        try await tradeRepository.refreshFilter(
            category: category,
            location: location,
            itemCategory: itemCategory,
            limit: limit ?? 10
        )
    }
    
    
    /// 페이지네이션 Query를 초기화하고 키워드에 해당하는 최신 Trade 목록을 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 Trade의 키워드
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: title, content, itemCategory가 키워드에 해당하는 Trade 배열
    public func refreshSearchTradeList(keyword: String, limit: Int?) async throws -> [Trade] {
        try await tradeRepository.refreshSearch(keyword: keyword, limit: limit ?? 10)
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
        
        try await tradeRepository.updateTrade(trade: trade, imageDatas: imageDatas)
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
        try await tradeRepository.likeTrade(tradeID: tradeID)
    }
    
    
    /// Trade를 삭제하는 메서드
    /// - Parameters:
    ///   - trade: 삭제하려는 trade의 정보
    public func deleteTrade(trade: Trade) async throws {
        try await tradeRepository.deleteTrade(trade: trade)
    }
    
    /// 검색 결과 페이지네이션 쿼리를 초기화하는 메서드
    ///
    /// 검색 뷰에서 벗어날 때마다 호출해줘야한다.
    public func resetQuery() {
        tradeRepository.resetQuery()
    }
    
}
