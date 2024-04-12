//
//  Category.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/5/24.
//

import Foundation

public enum Category: Int, Codable {
    case accua = 0
    case nanua, baccua, dasi
    
    public var description: String {
        switch self {
        case .accua: "아껴쓰기"
        case .nanua: "나눠쓰기"
        case .baccua: "바꿔쓰기"
        case .dasi: "다시쓰기"
        }
    }
}
