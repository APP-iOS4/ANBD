//
//  ArticleUsecase.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
public protocol ArticleUsecase {
    func writeArticle(article: Article, imageDatas: [Data]) async throws
    func loadArticle(articleID: String) async throws -> Article
    func loadArticleList() async throws -> [Article]
    func loadArticleList(category: ANBDCategory) async throws -> [Article]
    func loadArticleList(writerID: String) async throws -> [Article]
    func searchArticle(keyword: String) async throws -> [Article]
    func refreshAllArticleList() async throws -> [Article]
    func refreshCategoryArticleList(category: ANBDCategory) async throws -> [Article]
    func refreshWriterIDArticleList(writerID: String) async throws -> [Article]
    func refreshSearchArticleList(keyword: String) async throws -> [Article]
    func updateArticle(article: Article, imageDatas: [Data]) async throws
    func likeArticle(articleID: String) async throws
    func deleteArticle(article: Article) async throws
    func resetQuery()
}

@available(iOS 15, *)
public struct DefaultArticleUsecase: ArticleUsecase {
    
    let userRepository: UserRepository = DefaultUserRepository()
    let articleRepository: ArticleRepository = DefaultArticleRepository()
    let commentRepository: CommentRepository = DefaultCommentRepository()
    
    let storage = StorageManager.shared
    
    public init() { }
    
    
    /// Article을 작성하는 메서드
    ///  - Parameters:
    ///    - article: 작성한 Article
    ///    - imageDatas: 저장할 사진 Data 배열
    public func writeArticle(article: Article, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.uploadImageList(
            path: .article,
            containerID: article.id,
            imageDatas: imageDatas
        )
        var newArticle = article
        newArticle.imagePaths = imagePaths
        
        try await articleRepository.crateArticle(article: newArticle)
    }
    
    
    /// 특정 ID의 Article을 불러오는 메서드
    /// - Parameters:
    ///   - articleID: 불러올 Article의 ID
    /// - Returns: articleID가 일치하는 Article
    public func loadArticle(articleID: String) async throws -> Article {
        try await articleRepository.readArticle(articleID: articleID)
    }
    
    
    /// 모든 Article을 불러오는 메서드
    /// - Returns: Article 배열
    public func loadArticleList() async throws -> [Article] {
        try await articleRepository.readArticleList()
    }

    
    /// 카테고리가 일치하는 모든 Article을 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 Article의 카테고리
    /// - Returns: 카테고리가 일치하는 Article 배열
    public func loadArticleList(category: ANBDCategory) async throws -> [Article] {
        try await articleRepository.readArticleList(category: category)
    }
    
    
    /// writerID가 일치하는 모든 Article을 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Article의 writerID
    /// - Returns: writerID가 일치하는 Article 배열
    public func loadArticleList(writerID: String) async throws -> [Article] {
        try await articleRepository.readArticleList(writerID: writerID)
    }
    
    
    /// keyword로 Article을 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 keyword
    /// - Returns: title, content가 keyword에 해당하는 Article 배열
    public func searchArticle(keyword: String) async throws -> [Article] {
        try await articleRepository.readArticleList(keyword: keyword)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 최신 Article 목록 10개를 반환하는 메서드
    ///  - Returns: Article 배열
    public func refreshAllArticleList() async throws -> [Article] {
        try await articleRepository.refreshAll()
    }
    
    
    /// 페이지네이션 Query를 초기화하고 카테고리가 일치하는 최신 Article 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - category: 불러올 Article의 카테고리
    /// - Returns: 카테고리가 일치하는 Article 배열
    public func refreshCategoryArticleList(category: ANBDCategory) async throws -> [Article] {
        try await articleRepository.refreshCategory(category: category)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 작성자 ID가 일치하는 최신 Article 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Article의 writerID
    /// - Returns: writerID가 일치하는 Article 배열
    public func refreshWriterIDArticleList(writerID: String) async throws -> [Article] {
        try await articleRepository.refreshWriterID(writerID: writerID)
    }
    
    
    /// 페이지네이션 Query를 초기화하고 키워드에 해당하는 최신 Article 목록 10개를 불러오는 메서드
    /// - Parameters:
    ///   - keyword: 검색할 Article의 키워드
    /// - Returns: title, content가 키워드에 해당하는 Article 배열
    public func refreshSearchArticleList(keyword: String) async throws -> [Article] {
        try await articleRepository.refreshSearch(keyword: keyword)
    }
    
    
    /// Article을 수정하는 메서드
    /// - Parameters:
    ///   - article: 수정할 Article의 정보
    ///   - imageDatas: 수정할 이미지 Data 배열
    public func updateArticle(article: Article, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.updateImageList(
            path: .article,
            containerID: article.id,
            imagePaths: article.imagePaths,
            imageDatas: imageDatas
        )
        var updatedArticle = article
        updatedArticle.imagePaths = imagePaths
        
        try await articleRepository.updateArticle(article: article)
    }
    
    /// Article을 좋아요하는 메서드
    /// - Parameters:
    ///   - articleID: 좋아요할 Article의 ID
    public func likeArticle(articleID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        var userInfo = try await userRepository.readUserInfo(userID: userID)
        
        var articleInfo = try await articleRepository.readArticle(articleID: articleID)
        
        if userInfo.likeArticles.contains(articleID) {
            articleInfo.likeCount -= 1
            userInfo.likeArticles = userInfo.likeArticles.filter { $0 != articleID }
        } else {
            articleInfo.likeCount += 1
            userInfo.likeArticles.append(articleID)
        }
        
        try await articleRepository.updateArticle(article: articleInfo)
        try await userRepository.updateUserInfo(user: userInfo)
    }
    
    
    /// Article을 삭제하는 메서드
    /// - Parameters:
    ///   - article: 삭제할 Article의 정보
    ///
    /// 댓글 목록 -> 사진 -> 게시글 순으로 삭제됩니다.
    /// 삭제 성공 시 좋아요한 User들의 좋아요 목록에서도 사라집니다.
    public func deleteArticle(article: Article) async throws {
        try await commentRepository.deleteCommentList(articleID: article.id)
        try await storage.deleteImageList(path: .article, containerID: article.id, imagePaths: article.imagePaths)
        try await articleRepository.deleteArticle(article: article)
        try await userRepository.updateUserInfoList(articleID: article.id)
    }
    
    
    /// 검색 결과 페이지네이션 쿼리를 초기화하는 메서드
    ///
    /// 검색 뷰에서 벗어날 때마다 호출해줘야한다.
    public func resetQuery() {
        articleRepository.resetQuery()
    }
    
}
