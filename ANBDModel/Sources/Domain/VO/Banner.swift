//
//  Banner.swift
//
//
//  Created by 유지호 on 4/9/24.
//

import Foundation

@available(iOS 15.0, *)
public struct Banner: Codable, Identifiable {
    public let id: String
    public var createdAt: Date
    public var urlString: String
    public var thumbnailImageURLString: String
    
    public var url: URL {
        return URL(string: urlString)!
    }
    
    public var thumbnailImageURL: URL {
        return URL(string: thumbnailImageURLString)!
    }
    
    public init(
        id: String = UUID().uuidString,
        createdAt: Date = .now,
        urlString: String,
        thumbnailImageURLString: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.urlString = urlString
        self.thumbnailImageURLString = thumbnailImageURLString
    }
}
