//
//  ArticleRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public protocol ArticleRepository {
    func createArticle(article: Article, imageDatas: [Data]) async throws
    func readArticle(articleID: String) async throws -> Article
    func readRecentArticle(category: ANBDCategory) async throws -> Article
    func readArticleList(limit: Int) async throws -> [Article]
    func readArticleList(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Article]
    func readArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article]
    func readArticleList(keyword: String, limit: Int) async throws -> [Article]
    func refreshAll(limit: Int) async throws -> [Article]
    func refreshWriterID(writerID: String, category: ANBDCategory?, limit: Int) async throws -> [Article]
    func refreshOrder(category: ANBDCategory, by order: ArticleOrder, limit: Int) async throws -> [Article]
    func refreshSearch(keyword: String, limit: Int) async throws -> [Article]
    func updateArticle(article: Article, imageDatas: [Data]) async throws
    func likeArticle(articleID: String) async throws
    func deleteArticle(article: Article) async throws
    func resetQuery()
}
