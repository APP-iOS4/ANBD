//
//  ArticleViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

final class ArticleViewModel: ObservableObject {
    @Published var articlePath: NavigationPath = NavigationPath()
    
//    @Published var articleUsecase: ArticleUsecase
//    @Published var commentUsecase: CommentUsecase
    
    @Published var articles: Article?
//    @Published var comments: [Comment] = []
    
    @Published var sortOption: SortOption = .time

    @Published private(set) var filteredArticles: [Article] = []
    let mockArticleData: [Article] = [
    ]
    
    init() {
        filteredArticles = mockArticleData
    }
    
    enum SortOption {
        case time, likes, comments
    }
    
    func filteringArticles(category: ANBDCategory) {
        filteredArticles = mockArticleData.filter({ $0.category == category })
        
    }
    
    func updateArticles(category: ANBDCategory) {
        switch sortOption {
        case .time:
            if category == .accua {
                filteredArticles = mockArticleData.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = mockArticleData.filter { $0.category == .dasi }
            }
            break
        case .likes:
            // 좋아요순 정렬
            if category == .accua {
                filteredArticles = mockArticleData.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = mockArticleData.filter { $0.category == .dasi }
            }
            filteredArticles.sort(by: { $0.likeCount > $1.likeCount })
            break
        case .comments:
            // 댓글순 정렬
            if category == .accua {
                filteredArticles = mockArticleData.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = mockArticleData.filter { $0.category == .dasi }
            }
            filteredArticles.sort(by: { $0.commentCount > $1.commentCount })
            break
        }
    }
    
    func getSortOptionLabel() -> String {
        switch sortOption {
        case .time:
            return "최신순"
        case .likes:
            return "좋아요순"
        case .comments:
            return "댓글순"
        }
    }
}
