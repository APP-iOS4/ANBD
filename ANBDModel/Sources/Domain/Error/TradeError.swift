//
//  TradeError.swift
//
//
//  Created by 유지호 on 4/16/24.
//

import Foundation

public enum TradeError: Int, Error {
    case invalidWriterInfoField = 4020
    case invalidTitleContentField
    case invalidWantProductField
    case invalidImageField
    case invalidTradeIDField
    case invalidCategory
    case invalidKeyword
    
    public var message: String {
        switch self {
        case .invalidWriterInfoField: "거래글 필드 누락(작성자 id, nickname)"
        case .invalidTitleContentField: "거래글 필드 누락(제목, 내용)"
        case .invalidWantProductField: "거래글 필드 누락(wantProduct)"
        case .invalidImageField: "거래글 필드 누락(이미지)"
        case .invalidTradeIDField: "잘못된 거래글 ID"
        case .invalidCategory: "잘못된 거래글 카테고리(나,바 이외의 카테고리)"
        case .invalidKeyword: "잘못된 키워드"
        }
    }
}
