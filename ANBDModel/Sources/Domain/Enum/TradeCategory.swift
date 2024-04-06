//
//  TradeCategory.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum TradeCategory: Int, Codable, CaseIterable {
    case nanua = 0
    case baccua = 1
    
    public var description: String {
        switch self {
        case .nanua: "나눠쓰기"
        case .baccua: "바꿔쓰기"
        }
    }
    
    static public var allDescriptions: [String] {
        return TradeCategory.allCases.map { $0.description }
    }
}
