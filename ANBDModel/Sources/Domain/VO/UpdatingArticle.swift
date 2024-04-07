//
//  UpdatingArticle.swift
//  
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public struct UpdatingArticle: Identifiable {
    /// 게시글의 고유 식별값
    public private(set) var id: String
    
    /// 작성자의 ID
    public var writerID: String
    
    /// 게시글의 카테고리
    ///
    /// 0이면 아껴쓰기, 1이면 바꿔쓰기이다.
    public var category: ArticleCategory
    
    /// 게시글의 제목
    public var title: String
    
    /// 게시글의 내용
    public var content: String
    
    /// 게시글의 사진 URL 배열
    public var imageDatas: [Data]
}
