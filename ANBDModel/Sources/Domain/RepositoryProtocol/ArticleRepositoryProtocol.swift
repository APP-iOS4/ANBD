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
    func readArticleList() async throws -> [Article]
    func readArticleList(category: ANBDCategory) async throws -> [Article]
    func readArticleList(writerID: String) async throws -> [Article]
    func updateArticle(article: Article) async throws
    func deleteArticle(article: Article) async throws
}
