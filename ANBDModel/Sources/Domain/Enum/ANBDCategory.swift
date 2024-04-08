//
//  ANBDCategory.swift
//
//
//  Created by 유지호 on 4/8/24.
//

import Foundation

public enum ANBDCategory: Int, CaseIterable, Codable {
    case accua = 0
    case nanua = 1
    case baccua = 2
    case dasi = 3
    
    public var description: String {
        switch self {
        case .accua: "아껴쓰기"
        case .nanua: "나눠쓰기"
        case .baccua: "바꿔쓰기"
        case .dasi: "바꿔쓰기"
        }
    }
    
    static public var allDescriptions: [String] {
        return ANBDCategory.allCases.map { $0.description }
    }
}
