//
//  File.swift
//  
//
//  Created by 유지호 on 4/5/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
public protocol ArticleUsecaseProtocol {
    func writeArticle(article: Article, imageDatas: [Data]) async throws
    func loadArticle(articleID: String) async throws -> Article
    func loadUpdatingArticle(articleID: String) async throws -> UpdatingArticle
    func loadArticleList() async throws -> [Article]
    func loadArticleList(writerID: String) async throws -> [Article]
    func updateArticle(article: Article) async throws
    func likeArticle(articleID: String) async throws
    func deleteArticle(article: Article) async throws
}

@available(iOS 15, *)
public struct ArticleUsecase: ArticleUsecaseProtocol {
    
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
        let imagePaths = try await storage.uploadImageList(path: .article, containerID: article.id, imageDatas: imageDatas)
        let newArticle = Article(
            id: article.id,
            writerID: article.writerID,
            writerNickname: article.writerNickname,
            createdAt: article.createdAt,
            category: article.category,
            title: article.title,
            content: article.content,
            imagePaths: imagePaths
        )
        
        try await articleRepository.crateArticle(article: newArticle)
    }
    
    
    /// 특정 ID의 Article을 불러오는 메서드
    /// - Parameters:
    ///   - articleID: 불러올 Article의 ID
    /// - Returns: articleID가 일치하는 Article
    public func loadArticle(articleID: String) async throws -> Article {
        try await articleRepository.readArticle(articleID: articleID)
    }
    
    /// 수정할 특정 ID의 Article을 불러오는 메서드
    /// - Parameters:
    ///   - articleID: 불러올 Article의 ID
    /// - Returns: articleID가 일치하는 Image Data 배열을 포함한 UpdatingArticle
    public func loadUpdatingArticle(articleID: String) async throws -> UpdatingArticle {
        let articleInfo = try await articleRepository.readArticle(articleID: articleID)
        let imageDatas = try await storage.downloadImageList(path: .article, containerID: articleID, imagePaths: articleInfo.imagePaths)
        
        var upadatingArticle = articleInfo.toDomain()
        upadatingArticle.imageDatas = imageDatas
        
        return upadatingArticle
    }
    
    
    /// 모든 Article을 불러오는 메서드
    /// - Returns: Article 배열
    public func loadArticleList() async throws -> [Article] {
        try await articleRepository.readArticleList()
    }

    /// writerID가 일치하는 모든 Article을 불러오는 메서드
    /// - Parameters:
    ///   - writerID: 불러올 Article의 writerID
    /// - Returns: writerID가 일치하는 Article 배열
    public func loadArticleList(writerID: String) async throws -> [Article] {
        try await articleRepository.readArticleList(writerID: writerID)
    }
    
    /// Article을 수정하는 메서드
    /// - Parameters:
    ///   - article: 수정할 Article의 정보
    ///
    public func updateArticle(article: Article) async throws {
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
    
}
