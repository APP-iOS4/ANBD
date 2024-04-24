//
//  CommentError.swift
//
//
//  Created by 유지호 on 4/14/24.
//

public enum CommentError: Int, Error {
    case invalidCommentID = 4017
    case invalidParameter
    
    public var message: String {
        switch self {
        case .invalidCommentID: "잘못된 댓글 ID"
        case .invalidParameter: "댓글 필드 누락(내용)"
        }
    }
}
