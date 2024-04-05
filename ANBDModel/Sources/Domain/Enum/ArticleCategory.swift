//
//  ArticleCategory.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum ArticleCategory: Int, Codable, CaseIterable {
    case accua = 0
    case dasi = 1
    
    public var description: String {
        switch self {
        case .accua: "아껴쓰기"
        case .dasi: "바꿔쓰기"
        }
    }
}
