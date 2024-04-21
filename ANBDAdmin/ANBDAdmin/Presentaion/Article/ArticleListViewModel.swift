//
//  ArticleListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/12/24.
//

import Foundation
import ANBDModel

class ArticleListViewModel: ObservableObject {
    @Published var articleList: [Article] = []
    var deletedArticleID: String? // 삭제 변수
    let articleUsecase = DefaultArticleUsecase()

    func firstLoadArticles() {
        if articleList.isEmpty {
            Task {
                do {
                    let articles = try await articleUsecase.loadArticleList()
                                    DispatchQueue.main.async {
                                        self.articleList = articles
                                    }
                } catch {
                    print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func loadArticle(articleID: String) async throws -> Article {
        return try await articleUsecase.loadArticle(articleID: articleID)
    }
    func searchArticle(articleID: String) async {
        do {
            let searchedArticle = try await loadArticle(articleID: articleID)
            DispatchQueue.main.async {
                self.articleList = [searchedArticle]
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.articleList = []
            }
        }
    }
}
