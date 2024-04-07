//
//  Trade.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

@available(iOS 15, *)
public struct Trade: Codable, Identifiable, Hashable {
    /// 거래글의 고유 식별값
    public private(set) var id: String
    
    /// 작성자의 ID
    public var writerID: String
    
    /// 작성자의 닉네임
    public var writerNickname: String
    
    /// 거래글이 작성된 날짜
    public var createdAt: Date
    
    /// 거래글의 카테고리
    ///
    /// 0이면 나눠쓰기, 1이면 바꿔쓰기이다.
    public var category: TradeCategory
    
    /// 작성자의 물건 카테고리
    public var itemCategory: ItemCategory
    
    /// 작성자의 지역
    public var location: Location
    
    /// 거래글의 상태 (거래중, 거래완료)
    public var tradeState: TradeState
    
    /// 거래글의 제목
    public var title: String
    
    /// 거래글의 내용
    public var content: String
    
    /// 작성자의 물건
    public var myProduct: String
    
    /// 작성자가 원하는 물건
    public var wantProduct: String?
    
    /// 거래글의 이미지 Path 배열
    public var imagePaths: [String] = []
    
    
    public init(
        id: String = UUID().uuidString,
        writerID: String,
        writerNickname: String,
        createdAt: Date = .now,
        category: TradeCategory,
        itemCategory: ItemCategory,
        location: Location,
        tradeState: TradeState = .trading,
        title: String,
        content: String,
        myProduct: String,
        wantProduct: String? = nil,
        imagePaths: [String]
    ) {
        self.id = id
        self.writerID = writerID
        self.writerNickname = writerNickname
        self.createdAt = createdAt
        self.category = category
        self.itemCategory = itemCategory
        self.location = location
        self.tradeState = tradeState
        self.title = title
        self.content = content
        self.myProduct = myProduct
        self.wantProduct = wantProduct
        self.imagePaths = imagePaths
    }
}
