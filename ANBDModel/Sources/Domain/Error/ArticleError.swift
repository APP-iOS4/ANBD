//
//  ArticleError.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum ArticleError: Int, Error {
    case invalidWriterInfoField = 4011
    case invalidTitleContentField
    case invalidImageField
    case invalidArticleIDField
    case invalidCategory
    case invalidKeyword
    
    public var message: String {
        switch self {
        case .invalidWriterInfoField: "게시글 필드 누락(작성자 id, nickname)"
        case .invalidTitleContentField: "게시글 필드 누락(제목, 내용)"
        case .invalidImageField: "게시글 필드 누락(이미지)"
        case .invalidArticleIDField: "잘못된 게시글 ID"
        case .invalidCategory: "잘못된 게시글 카테고리(아,다 이외의 카테고리)"
        case .invalidKeyword: "잘못된 키워드"
        }
    }
}
