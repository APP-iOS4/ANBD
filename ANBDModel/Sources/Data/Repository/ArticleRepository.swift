//
//  DefaultArticleRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@available(iOS 15, *)
final class DefaultArticleRepository: ArticleRepository {
    
    private let articleDataSource: ArticleDataSource
    private let commentDataSource: CommentDataSource
    private let userDataSource: UserDataSource
    
    private let storage = StorageManager.shared
    
    init(
        articleDataSource: ArticleDataSource = DefaultArticleDataSource(),
        commentDataSource: CommentDataSource = DefaultCommentDataSource(),
        userDataSource: UserDataSource = DefaultUserDataSource()
    ) {
        self.articleDataSource = articleDataSource
        self.commentDataSource = commentDataSource
        self.userDataSource = userDataSource
    }
    
    
    // MARK: Create
    func createArticle(article: Article, imageDatas: [Data]) async throws {
        do {
            let imagePaths = try await storage.uploadImageList(
                path: .article,
                containerID: article.id,
                imageDatas: imageDatas
            )
            var newArticle = article
            newArticle.imagePaths = imagePaths
            
            try await articleDataSource.createArticle(article: newArticle)
        } catch DBError.setDocumentError {
            throw ArticleError.createArticleError(code: 4011, message: "Article을 추가하는데 실패했습니다.")
        }
    }
    
    
    // MARK: Read
    func readArticle(articleID: String) async throws -> Article {
        do {
            let article = try await articleDataSource.readArticle(articleID: articleID)
            return article
        } catch DBError.getDocumentError {
            throw ArticleError.readArticleError(code: 4012, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    func readRecentArticle(category: ANBDCategory) async throws -> Article {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        do {
            let article = try await articleDataSource.readRecentArticle(category: category)
            return article
        } catch DBError.getDocumentError {
            throw ArticleError.readArticleError(code: 4012, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    func readArticleList(limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readArticleList(limit: limit)
        return articleList
    }
    
    func readArticleList(writerID: String, limit: Int) async throws -> [Article] {
        let articleList = try await articleDataSource.readArticleList(writerID: writerID, limit: limit)
        return articleList
    }
    
    func readArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        let articleList = try await articleDataSource.readArticleList(category: category, by: order, limit: limit)
        return articleList
    }
    
    func readArticleList(keyword: String, limit: Int) async throws -> [Article] {
        if keyword.isEmpty {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        let articleList = try await articleDataSource.readArticleList(keyword: keyword, limit: limit)
        return articleList
    }
    
    func refreshAll(limit: Int) async throws -> [Article] {
        do {
            let refreshedList = try await articleDataSource.refreshAll(limit: limit)
            return refreshedList
        } catch DBError.getDocumentError {
            throw ArticleError.readArticleError(code: 4011, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    func refreshWriterID(writerID: String, limit: Int) async throws -> [Article] {
        if writerID.isEmpty {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        do {
            let refreshedList = try await articleDataSource.refreshWriterID(writerID: writerID, limit: limit)
            return refreshedList
        } catch {
            throw ArticleError.readArticleError(code: 4011, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    func refreshOrder(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article] {
        guard category == .accua || category == .dasi else {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        do {
            let refreshedList = try await articleDataSource.refreshOrder(category: category, by: order, limit: limit)
            return refreshedList
        } catch {
            throw ArticleError.readArticleError(code: 4011, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    func refreshSearch(keyword: String, limit: Int) async throws -> [Article] {
        if keyword.isEmpty {
            throw ArticleError.invalidParameter(code: 4010, message: "잘못된 매개변수입니다.")
        }
        
        do {
            let refreshedList = try await articleDataSource.refreshSearch(keyword: keyword, limit: limit)
            return refreshedList
        } catch {
            throw ArticleError.readArticleError(code: 4011, message: "Article을 읽어오는데 실패했습니다.")
        }
    }
    
    
    // MARK: Update
    func updateArticle(article: Article, imageDatas: [Data]) async throws {
        do {
            let imagePaths = try await storage.updateImageList(
                path: .article,
                containerID: article.id,
                imagePaths: article.imagePaths,
                imageDatas: imageDatas
            )
            var updatedArticle = article
            updatedArticle.imagePaths = imagePaths
            
            try await articleDataSource.updateArticle(article: updatedArticle)
        } catch DBError.updateDocumentError {
            throw ArticleError.updateArticleError(code: 4013, message: "Article을 업데이트하는데 실패했습니다.")
        }
    }
    
    func likeArticle(articleID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        var userInfo = try await userDataSource.readUserInfo(userID: userID)
        var articleInfo = try await articleDataSource.readArticle(articleID: articleID)
        
        if userInfo.likeArticles.contains(articleID) {
            articleInfo.likeCount -= 1
            userInfo.likeArticles = userInfo.likeArticles.filter { $0 != articleID }
        } else {
            articleInfo.likeCount += 1
            userInfo.likeArticles.append(articleID)
        }
        
        try await articleDataSource.updateArticle(article: articleInfo)
        try await userDataSource.updateUserInfo(user: userInfo)
    }
    
    
    // MARK: Delete
    func deleteArticle(article: Article) async throws {
        do {
            try await commentDataSource.deleteCommentList(articleID: article.id)
            try await storage.deleteImageList(path: .article, containerID: article.id, imagePaths: article.imagePaths)
            try await articleDataSource.deleteArticle(article: article)
            try await userDataSource.updateUserInfoList(articleID: article.id)
        } catch DBError.deleteDocumentError {
            throw ArticleError.deleteArticleError(code: 4014, message: "Article을 삭제하는데 실패했습니다.")
        }
    }
    
    func resetQuery() {
        articleDataSource.resetQuery()
    }
    
}
