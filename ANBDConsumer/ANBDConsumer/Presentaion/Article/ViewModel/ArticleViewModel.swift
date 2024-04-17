//
//  ArticleViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

@MainActor
final class ArticleViewModel: ObservableObject {
    
    private let articleUseCase: ArticleUsecase = DefaultArticleUsecase()
    private let storageManager = StorageManager.shared
    @Published var articles: [Article] = []

    @Published var articlePath: NavigationPath = NavigationPath()
    
//    @Published var accuaArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", imagePaths: [], thumbnailImagePath: )
//    @Published var dasiArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",con, thumbnailImagePath: <#String#>tent: "", imagePaths: [])
//    @Published var comments: [Comment] = []

    @Published var sortOption: ArticleOrder = .latest
    
    @Published private(set) var filteredArticles: [Article] = []
    @Published private var isLiked: Bool = false

    let mockArticleData: [Article] = [
    ]
    
    init() {

    }
    
    func filteringArticles(category: ANBDCategory) {
        filteredArticles = articles.filter({ $0.category == category })
    }
    
    func loadAllArticles() async {
        do {
            try await self.articles.append(contentsOf: articleUseCase.loadArticleList(limit: 10))
            print("read")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reloadAllArticles() async {
        do {
            print("read")
            self.articles = try await articleUseCase.refreshAllArticleList(limit: 10)
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func filteringArticles(category: ANBDCategory) async {
//        do {
//            filteredArticles.append(
//                contentsOf: try await articleUseCase.loadArticleList(category: category, by: .latest, limit: 10)
//                )
//            print(filteredArticles)
//        } catch {
//            print(error.localizedDescription)
//        }
//    } 
    
    func refreshSortedArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async {
        do {
            filteredArticles.append(
                contentsOf:  try await articleUseCase.refreshSortedArticleList(category: category, by: sortOption, limit: 10)
                )
            print(filteredArticles)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func writeArticle(article: Article, imageDatas: [Data]) async {
        do {
            try await articleUseCase.writeArticle(article: article, imageDatas: imageDatas)

        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateArticle(article: Article, imageDatas: [Data]) async {
        do {
            try await articleUseCase.updateArticle(article: article, imageDatas: imageDatas)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteArticle(article: Article) async {
        do {
            try await articleUseCase.deleteArticle(article: article)
        } catch {
            print(error.localizedDescription)
            print("삭제실패")
        }
    }
    
    func likeArticle(articleID: String) async {
        do {
            try await articleUseCase.likeArticle(articleID: articleID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func resetQuery() {
        articleUseCase.resetQuery()
    }
    
    func toggleLikeArticle(articleID: String) async {
        do {
            if isLiked {
                try await articleUseCase.likeArticle(articleID: articleID)
                isLiked = false
            } else {
                try await articleUseCase.likeArticle(articleID: articleID)
                isLiked = true
            }
            isLiked.toggle()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateLikeCount(articleID: String, increment: Bool) async {
        if let index = filteredArticles.firstIndex(where: { $0.id == articleID }) {
            if increment {
                filteredArticles[index].likeCount += 1
            } else {
                filteredArticles[index].likeCount -= 1
            }
        }
    }
    
    func getSortOptionLabel() -> String {
        switch sortOption {
        case .latest:
            return "최신순"
        case .mostLike:
            return "좋아요순"
        case .mostComment:
            return "댓글순"
        }
    }
    
}
