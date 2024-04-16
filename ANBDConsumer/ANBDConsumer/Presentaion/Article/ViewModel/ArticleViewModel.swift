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
    
    @Published var articlePath: NavigationPath = NavigationPath()
    
    @Published var accuaArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", imagePaths: [])
    @Published var dasiArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", imagePaths: [])
    
    @Published private(set) var article: [Article] = []
//    @Published var comments: [Comment] = []

    @Published var sortOption: ArticleOrder = .latest

    @Published private(set) var filteredArticles: [Article] = []

    let mockArticleData: [Article] = [
    ]
    
    init() {

    }
    
    func filteringArticles(category: ANBDCategory) async {
        do {
            filteredArticles = try await articleUseCase.loadArticleList(category: category, by: .latest, limit: 10)
        } catch {
            print(error.localizedDescription)
        }
    } 
    
    func filteringArticles(category: ANBDCategory, by order: ArticleOrder, limit: Int) async {
        do {
            filteredArticles = try await articleUseCase.refreshSortedArticleList(category: category, by: sortOption, limit: 10)
            
        } catch {
            print(error.localizedDescription)
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
