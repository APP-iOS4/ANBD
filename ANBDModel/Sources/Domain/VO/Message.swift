//
//  Message.swift
//
//
//  Created by 김성민 on 3/22/24.
//

import Foundation

public struct Message: Identifiable , Codable {
    public var id: String = UUID().uuidString
    
    public let userID: String
    public var userNickname: String
    
    public var createdAt: Date = Date()
    
    public var content: String?
    public var imagePath: String?
    
    public var leaveUsers : [String]
    
    public var dateString : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: createdAt)
    }
    public var dateStringWithYear: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 (E)"
            dateFormatter.locale = Locale(identifier:"ko_KR")
            return dateFormatter.string(from: createdAt)
    }
    
    public init(userID: String, userNickname: String, content: String? = nil, image: String? = nil) {
        self.userID = userID
        self.userNickname = userNickname
        self.content = content
        self.imagePath = image
        self.leaveUsers = []
    }
}
