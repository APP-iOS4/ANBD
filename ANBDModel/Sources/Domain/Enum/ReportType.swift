//
//  File.swift
//  
//
//  Created by 정운관 on 4/20/24.
//

import Foundation

public enum ReportType: String ,CaseIterable, Codable{
    
    case article = "게시물"
    case trade = "거래글"
    case comment = "댓글"
    case messages = "메시지"
    case chatRoom = "채팅방"
    case users = "유저"
    
    public var description: String {
        switch self {
        case .article: "신고된 게시물"
        case .trade: "신고된 거래글"
        case .comment: "신고된 댓글"
        case .messages: "신고된 메시지"
        case .chatRoom: "신고된 채팅방"
        case .users: "신고된 유저"
        }
    }
}
