//
//  ArticleRepository.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

@available(iOS 15, *)
public protocol ArticleRepository {
    func crateArticle(article: Article) async throws
    func readArticle(articleID: String) async throws -> Article
    func readRecentArticle(category: ANBDCategory) async throws -> Article
    func readArticleList() async throws -> [Article]
    func readArticleList(writerID: String) async throws -> [Article]
    func readArticleList(by order: ArticleOrder) async throws -> [Article]
    func readArticleList(keyword: String) async throws -> [Article]
    func refreshAll() async throws -> [Article]
    func refreshWriterID(writerID: String) async throws -> [Article]
    func refreshOrder(by order: ArticleOrder) async throws -> [Article]
    func refreshSearch(keyword: String) async throws -> [Article]
    func updateArticle(article: Article) async throws
    func deleteArticle(article: Article) async throws
    func resetQuery()
}
