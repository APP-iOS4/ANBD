//
//  ArticleUsecase.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

@available(iOS 15, *)
public protocol ArticleUsecase {
    func writeArticle(article: Article, imageDatas: [Data]) async throws
    func loadArticle(articleID: String) async throws -> Article
    func loadRecentArticle(category: ANBDCategory) async throws -> Article
    func loadArticleList(limit: Int) async throws -> [Article]
    func loadArticleList(writerID: String, limit: Int) async throws -> [Article]
    func loadArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article]
    func searchArticle(keyword: String, limit: Int) async throws -> [Article]
    func refreshAllArticleList(limit: Int) async throws -> [Article]
    func refreshWriterIDArticleList(writerID: String, limit: Int) async throws -> [Article]
    func refreshSortedArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article]
    func refreshSearchArticleList(keyword: String, limit: Int) async throws -> [Article]
    func updateArticle(article: Article, imageDatas: [Data]) async throws
    func likeArticle(articleID: String) async throws
    func deleteArticle(article: Article) async throws
    func resetQuery()
}

@available(iOS 15, *)
public struct DefaultArticleUsecase: ArticleUsecase {
    
    private let articleRepository: ArticleRepository = DefaultArticleRepository()
    
    public init() { }
    
    
    /// Article을 작성하는 메서드
    ///  - Parameters:
    ///    - article: 작성한 Article
    ///    - imageDatas: 저장할 사진 Data 배열
    public func writeArticle(article: Article, imageDatas: [Data]) async throws {
        guard article.category == .accua || article.category == .dasi else {
            throw ArticleError.invalidCategory
        }
        
        if article.title.isEmpty || article.content.isEmpty {
            throw ArticleError.invalidTitleContentField
        } else if imageDatas.isEmpty {
            throw ArticleError.invalidImageField
        }
        
        try await articleRepository.createArticle(article: article, imageDatas: imageDatas)
    }
    
    
    /// 특정 ID의 Article을 불러오는 메서드
    /// - Parameters:
    ///   - articleID: 불러올 Article의 ID
    /// - Returns: articleID가 일치하는 Article
    public func loadArticle(articleID: String) async throws -> Article {
        if articleID.isEmpty {
            throw ArticleError.invalidArticleIDField
        }
        
        let article = try await articleRepository.readArticle(articleID: articleID)
        return article
    }
    
    
    /// 해당하는 카테고리의 최신 Article을 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 최신 Article의 카테고리
    /// - Returns: 카테고리가 일치하는 최신 Article
    public func loadRecentArticle(category: ANBDCategory) async throws -> Article {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidCategory
        }
        
        let recentArticle = try await articleRepository.readRecentArticle(category: category)
        return recentArticle
    }
    
    
    /// 모든 Article을 불러오는 메서드
    /// - Returns: Article 배열
    public func loadArticleList(limit: Int = 10) async throws -> [Article] {
        let articleList = try await articleRepository.readArticleList(limit: limit)
        return articleList
    }
    
    
    /// writerID가 일치하는 모든 Article을 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Article의 writerID
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: writerID가 일치하는 Article 배열
    public func loadArticleList(writerID: String, limit: Int = 10) async throws -> [Article] {
        if writerID.isEmpty {
            throw ArticleError.invalidWriterInfoField
        }
        
        let articleList = try await articleRepository.readArticleList(writerID: writerID, limit: limit)
        return articleList
    }
    
    
    /// 정렬 방식에 따라 정렬된 모든 Article을 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 Article의 카테고리 (0이면 아, 3이면 다)
    ///   - order: 불러올 Article의 정렬 방식
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 정렬된 Article 배열
    public func loadArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int = 10) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidCategory
        }
        
        let articleList = try await articleRepository.readArticleList(category: category, by: order, limit: limit)
        return articleList
    }
    
    
    /// keyword로 Article을 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 keyword
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: title, content가 keyword에 해당하는 Article 배열
    public func searchArticle(keyword: String, limit: Int = 10) async throws -> [Article] {
        if keyword.isEmpty {
            throw ArticleError.invalidKeyword
        }
        
        let articleList = try await articleRepository.readArticleList(keyword: keyword, limit: limit)
        return articleList
    }
    
    
    /// 페이지네이션 Query를 초기화하고 최신 Article 목록을 반환하는 메서드
    /// - Parameters:
    ///  - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    ///  - Returns: Article 배열
    public func refreshAllArticleList(limit: Int = 10) async throws -> [Article] {
        let articleList = try await articleRepository.refreshAll(limit: limit)
        return articleList
    }
    
    
    /// 페이지네이션 Query를 초기화하고 작성자 ID가 일치하는 최신 Article 목록을 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Article의 writerID
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: writerID가 일치하는 Article 배열
    public func refreshWriterIDArticleList(writerID: String, limit: Int = 10) async throws -> [Article] {
        if writerID.isEmpty {
            throw ArticleError.invalidWriterInfoField
        }
        
        let articleList = try await articleRepository.refreshWriterID(writerID: writerID, limit: limit)
        return articleList
    }
    
    
    /// 페이지네이션 Query를 초기화하고 정렬 방식에 따라 정렬된 Article 목록을 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 Article의 카테고리 (0이면 아, 3이면 다)
    ///   - order: 불러올 Article의 정렬 방식
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: 정렬된 Article 배열
    public func refreshSortedArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int = 10) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidCategory
        }
        
        let articleList = try await articleRepository.refreshOrder(category: category, by: order, limit: limit)
        return articleList
    }
    
    
    /// 페이지네이션 Query를 초기화하고 키워드에 해당하는 최신 Article 목록을 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 Article의 키워드
    ///   - limit: 가져오고 싶은 갯수. 기본값은 10이다.
    /// - Returns: title, content가 키워드에 해당하는 Article 배열
    public func refreshSearchArticleList(keyword: String, limit: Int = 10) async throws -> [Article] {
        if keyword.isEmpty {
            throw ArticleError.invalidKeyword
        }
        
        let articleList = try await articleRepository.refreshSearch(keyword: keyword, limit: limit)
        return articleList
    }
    
    
    /// Article을 수정하는 메서드
    /// - Parameters:
    ///   - article: 수정할 Article의 정보
    ///   - imageDatas: 수정할 이미지 Data 배열
    public func updateArticle(article: Article, imageDatas: [Data]) async throws {
        guard article.category == .accua || article.category == .dasi else {
            throw ArticleError.invalidCategory
        }
        
        if imageDatas.isEmpty {
            throw ArticleError.invalidImageField
        }
        
        try await articleRepository.updateArticle(article: article, imageDatas: imageDatas)
    }
    
    /// Article을 좋아요하는 메서드
    /// - Parameters:
    ///   - articleID: 좋아요할 Article의 ID
    public func likeArticle(articleID: String) async throws {
        if articleID.isEmpty {
            throw ArticleError.invalidArticleIDField
        }
        
        try await articleRepository.likeArticle(articleID: articleID)
    }
    
    
    /// Article을 삭제하는 메서드
    /// - Parameters:
    ///   - article: 삭제할 Article의 정보
    ///
    /// 댓글 목록 -> 사진 -> 게시글 순으로 삭제됩니다.
    /// 삭제 성공 시 좋아요한 User들의 좋아요 목록에서도 사라집니다.
    public func deleteArticle(article: Article) async throws {
        try await articleRepository.deleteArticle(article: article)
    }
    
    
    /// 검색 결과 페이지네이션 쿼리를 초기화하는 메서드
    ///
    /// 검색 뷰에서 벗어날 때마다 호출해줘야한다.
    public func resetQuery() {
        articleRepository.resetQuery()
    }
    
}
