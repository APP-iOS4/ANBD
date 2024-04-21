//
//  DefaultArticleRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
struct ArticleRepositoryImpl: ArticleRepository {
    
    private let articleDataSource: any Postable<Article>
    private let commentDataSource: any Postable<Comment>
    private let userDataSource: UserDataSource
    
    private let storage = StorageManager.shared
    
    init(
        articleDataSource: any Postable<Article> = PostDataSource<Article>(database: .articleDatabase),
        commentDataSource: any Postable<Comment> = PostDataSource<Comment>(database: .commentDatabase),
        userDataSource: UserDataSource = DefaultUserDataSource()
    ) {
        self.articleDataSource = articleDataSource
        self.commentDataSource = commentDataSource
        self.userDataSource = userDataSource
    }
    
    
    // MARK: Create
    func createArticle(article: Article, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.uploadImageList(
            path: .article,
            containerID: article.id,
            imageDatas: imageDatas
        )
        var newArticle = article
        newArticle.thumbnailImagePath = imagePaths.first ?? ""
        
        if !imagePaths.isEmpty {
            newArticle.imagePaths = Array(imagePaths[1...])
        }
        
        try await articleDataSource.createItem(item: newArticle)
    }
    
    
    // MARK: Read
    func readArticle(articleID: String) async throws -> Article {
        let article = try await articleDataSource.readItem(itemID: articleID)
        return article
    }
    
    func readRecentArticle(category: ANBDCategory) async throws -> Article {
        let article = try await articleDataSource.readRecentItem(category: category)
        return article
    }
    
    func readArticleList(limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readItemList(limit: limit)
        return articleList
    }
    
    func readArticleList(writerID: String, limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readItemList(writerID: writerID, limit: limit)
        return articleList
    }
    
    func readArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readItemList(category: category, by: order, limit: limit)
        return articleList
    }
    
    func readArticleList(keyword: String, limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readItemList(keyword: keyword, limit: limit)
        return articleList
    }
    
    func refreshAll(limit: Int) async throws -> [Article] {
        let refreshedList = try await articleDataSource.refreshAll(limit: limit)
        return refreshedList
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Article] {
        let refreshedList = try await articleDataSource.refreshWriterID(writerID: writerID, limit: limit)
        return refreshedList
    }
    
    func refreshOrder(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        let refreshedList = try await articleDataSource.refreshOrder(category: category, by: order, limit: limit)
        return refreshedList
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Article] {
        let refreshedList = try await articleDataSource.refreshSearch(keyword: keyword, limit: limit)
        return refreshedList
    }
    
    
    // MARK: Update
    func updateArticle(article: Article, imageDatas: [Data]) async throws {
        let imagePaths = try await storage.updateImageList(
            path: .article,
            containerID: article.id,
            imagePaths: article.imagePaths,
            imageDatas: imageDatas
        )
        var updatedArticle = article
        updatedArticle.thumbnailImagePath = imagePaths.first ?? ""
        
        if !imagePaths.isEmpty {
            updatedArticle.imagePaths = Array(imagePaths[1...])
        }
        
        try await articleDataSource.updateItem(item: updatedArticle)
    }
    
    func likeArticle(articleID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw UserError.invalidUserID
        }
        
        var userInfo = try await userDataSource.readUserInfo(userID: userID)
        var articleInfo = try await articleDataSource.readItem(itemID: articleID)
        
        if userInfo.likeArticles.contains(articleID) {
            articleInfo.likeCount -= 1
            userInfo.likeArticles = userInfo.likeArticles.filter { $0 != articleID }
        } else {
            articleInfo.likeCount += 1
            userInfo.likeArticles.append(articleID)
        }
        
        try await articleDataSource.updateItem(item: articleInfo)
        try await userDataSource.updateUserInfo(user: userInfo)
    }
    
    
    // MARK: Delete
    func deleteArticle(article: Article) async throws {
        try await commentDataSource.deleteItemList(articleID: article.id)
        
        if !article.thumbnailImagePath.isEmpty {
            try await storage.deleteImage(
                path: .article,
                containerID: "\(article.id)/thumbnail",
                imagePath: article.thumbnailImagePath
            )
        }
        
        try await storage.deleteImageList(
            path: .article,
            containerID: article.id,
            imagePaths: article.imagePaths
        )
        try await articleDataSource.deleteItem(itemID: article.id)
        try await userDataSource.updateUserInfoList(articleID: article.id)
    }
    
    func resetQuery() {
        articleDataSource.resetSearchQuery()
    }
    
}
