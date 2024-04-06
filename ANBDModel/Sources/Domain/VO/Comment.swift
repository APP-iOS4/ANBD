//
//  Comment.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public struct Comment: Codable, Identifiable {
    public var id: String
    public var articleID: String
    
    public var writerID: String
    public var writerNickname: String
    public var writerProfileImageURL: String
    
    public var createdAt: Date
    public var content: String
    
    public init(
        id: String = UUID().uuidString,
        articleID: String,
        writerID: String,
        writerNickname: String,
        writerProfileImageURL: String,
        createdAt: Date = .now,
        content: String
    ) {
        self.id = id
        self.articleID = articleID
        self.writerID = writerID
        self.writerNickname = writerNickname
        self.writerProfileImageURL = writerProfileImageURL
        self.createdAt = createdAt
        self.content = content
    }
}
