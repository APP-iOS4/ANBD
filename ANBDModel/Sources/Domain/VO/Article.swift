//
//  Article.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public struct Article: Codable, Identifiable, Hashable {
    /// 게시글의 고유 식별값
    public private(set) var id: String
    
    /// 작성자의 ID
    public var writerID: String
    
    /// 작성자의 닉네임
    public var writerNickname: String
    
    /// 게시글이 작성된 날짜
    public var createdAt: Date
    
    /// 게시글의 카테고리
    ///
    /// 0이면 아껴쓰기, 1이면 다시쓰기이다.
    public var category: ArticleCategory
    
    /// 게시글의 제목
    public var title: String
    
    /// 게시글의 내용
    public var content: String
    
    /// 게시글의 이미지 Path 배열
    public var imagePaths: [String]
    
    /// 게시글의 좋아요 수
    public var likeCount: Int
    
    /// 게시글의 댓글 수
    public var commentCount: Int
    

    public init(
        id: String = UUID().uuidString,
        writerID: String,
        writerNickname: String,
        createdAt: Date = .now,
        category: ArticleCategory,
        title: String,
        content: String,
        imagePaths: [String] = [],
        likeCount: Int = 0,
        commentCount: Int = 0
    ) {
        self.id = id
        self.writerID = writerID
        self.writerNickname = writerNickname
        self.createdAt = createdAt
        self.category = category
        self.title = title
        self.content = content
        self.imagePaths = imagePaths
        self.likeCount = likeCount
        self.commentCount = commentCount
    }
}
