//
//  ChannelError.swift
//
//
//  Created by 유지호 on 4/17/24.
//

import Foundation

public enum ChannelError: Int, Error {
    case invalidUserInfo = 4030
    case invalidParticipantInfo
    case invalidChannelID
    case invalidTradeID
    
    public var message: String {
        switch self {
        case .invalidUserInfo: "채널 필드 누락(사용자 id, nickname)"
        case .invalidParticipantInfo: "채널 필드 누락(참여자 id, nickname)"
        case .invalidChannelID: "채널 필드 누락(채널 id)"
        case .invalidTradeID: "채널 필드 누락(거래글 id)"
        }
    }
}
