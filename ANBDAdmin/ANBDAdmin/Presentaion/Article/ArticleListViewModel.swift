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
    var deletedArticleID: String?
    let articleUsecase = DefaultArticleUsecase()
    @Published var canLoadMore: Bool = true

    
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
    func loadMoreArticles(){ //10개씩 불러옴
        guard canLoadMore else { return }

        Task {
            do {
                let articles = try await articleUsecase.loadArticleList()
                DispatchQueue.main.async {
                    self.articleList.append(contentsOf: articles)
                    if articles.count < 10 {
                        self.canLoadMore = false
                    }
                }
            } catch {
                print("게시물 목록을 가져오는데 실패했습니다: \(error)")
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
