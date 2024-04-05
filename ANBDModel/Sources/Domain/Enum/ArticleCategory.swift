//
//  ArticleCategory.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum ArticleCategory: Int, Codable {
    case accua = 0
    case baccua = 1
    
    public var description: String {
        switch self {
        case .accua: "아껴쓰기"
        case .baccua: "바꿔쓰기"
        }
    }
}
