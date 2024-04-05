//
//  Trade.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

@available(iOS 15, *)
public struct Trade: Codable, Identifiable {
    public private(set) var id: String
    
    public var writerID: String
    public var writerNickname: String
    
    public var createdAt: Date
    public var category: TradeCategory
    
    public var tradeState: TradeState
    
    public var title: String
    public var content: String
    
    public var myProduct: String?
    public var wantProduct: String?
    
    public var imagePaths: [String] = []
    
    public init(
        id: String = UUID().uuidString,
        writerID: String,
        writerNickname: String,
        createdAt: Date = .now,
        category: TradeCategory,
        tradeState: TradeState = .trading,
        title: String,
        content: String,
        myProduct: String? = nil,
        wantProduct: String? = nil,
        imagePaths: [String]
    ) {
        self.id = id
        self.writerID = writerID
        self.writerNickname = writerNickname
        self.createdAt = createdAt
        self.category = category
        self.tradeState = tradeState
        self.title = title
        self.content = content
        self.myProduct = myProduct
        self.wantProduct = wantProduct
        self.imagePaths = imagePaths
    }
}
