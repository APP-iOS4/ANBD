//
//  ArticleError.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum ArticleError: Error {
    case invalidParameter(code: Int, message: String)
    case createArticleError(code: Int, message: String)
    case readArticleError(code: Int, message: String)
    case updateArticleError(code: Int, message: String)
    case deleteArticleError(code: Int, message: String)
}
