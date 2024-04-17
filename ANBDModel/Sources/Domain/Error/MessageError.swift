//
//  MessageError.swift
//
//
//  Created by 유지호 on 4/17/24.
//

import Foundation

public enum MessageError: Int, Error {
    case invalidUserInfo = 4040
    case invalidChannelID
    case invalidContent
    
    public var message: String {
        switch self {
        case .invalidUserInfo: "메세지 필드 누락(사용자 id, nickname)"
        case .invalidChannelID: "메세지 필드 누락(채널 id)"
        case .invalidContent: "메세지 필드 누락(내용)"
        }
    }
}
