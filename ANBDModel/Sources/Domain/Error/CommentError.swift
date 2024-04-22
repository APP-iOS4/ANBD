//
//  CommentError.swift
//
//
//  Created by 유지호 on 4/14/24.
//

public enum CommentError: Error {
    case invalidParameter(code: Int, message: String)
    case createCommentError(code: Int, message: String)
    case readCommentError(code: Int, message: String)
    case updateCommentError(code: Int, message: String)
    case deleteCommentError(code: Int, message: String)
}
