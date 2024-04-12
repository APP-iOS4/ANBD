//
//  Chats.swift
//  modeltest
//
//  Created by 정운관 on 3/23/24.
//

import Foundation

public struct Channel: Identifiable , Codable {
    public var id: String = UUID().uuidString
    
    public let users : [String]
    public let userNicknames : [String]
    public let lastMessage : String
    public let lastSendDate : Date
    public let lastSendId : String
    public let unreadCount : Int
    public let tradeId: String
    public var leaveUsers : [String]
    
    private static var dateFormatter : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter
    }()
    
    public var lastDateString: String {
        return Channel.dateFormatter.string(from: lastSendDate)
    }
    
    public init(participants: [String], participantNicknames: [String], lastMessage: String, lastSendDate: Date, lastSendId: String, unreadCount: Int, tradeId: String) {
        self.users = participants
        self.userNicknames = participantNicknames
        self.lastMessage = lastMessage
        self.lastSendDate = lastSendDate
        self.lastSendId = lastSendId
        self.unreadCount = unreadCount
        self.tradeId = tradeId
        self.leaveUsers = []
    }
}

