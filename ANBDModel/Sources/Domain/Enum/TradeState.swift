//
//  TradeState.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum TradeState: Int, Codable {
    case trading = 0
    case finish
    
    public var description: String {
        switch self {
        case .trading: "거래중"
        case .finish: "거래완료"
        }
    }
}
