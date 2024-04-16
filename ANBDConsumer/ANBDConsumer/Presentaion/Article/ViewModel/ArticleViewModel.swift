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
        .init(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "아껴제목1", content: "내용내용5", imagePaths: ["DummyImage1"], likeCount: 1, commentCount: 2),
        .init(writerID: "writerID", writerNickname: "닉네임", category: .accua, title: "아껴제목2", content: "내용내용4", imagePaths: ["DummyPuppy3"], likeCount: 50, commentCount: 4),
        .init(writerID: "writerID", writerNickname: "김기표", category: .accua, title: "아껴제목3", content: "내용내용3", imagePaths: ["DummyPuppy4"], likeCount: 100, commentCount: 3),
        .init(writerID: "writerID", writerNickname: "닉네임4", category: .accua, title: "아껴제목4", content: "내용내용2", imagePaths: ["DummyImage1"], likeCount: 4, commentCount: 20),
        .init(writerID: "writerID", writerNickname: "닉네임5", category: .accua, title: "아껴제목5", content: "내용내용1", imagePaths: ["DummyPuppy3"], likeCount: 20, commentCount: 10),
        .init(writerID: "writerID", writerNickname: "닉네임1", category: .dasi, title: "다시제목1", content: "내용내용5", imagePaths: ["DummyImage1"], likeCount: 400, commentCount: 25),
        .init(writerID: "writerID", writerNickname: "닉네임2", category: .dasi, title: "다시제목2", content: "내용내용4", imagePaths: ["DummyPuppy2"], likeCount: 2, commentCount: 420),
        .init(writerID: "writerID", writerNickname: "닉네임3", category: .dasi, title: "다시제목3", content: "내용내용3", imagePaths: ["DummyPuppy3"], likeCount: 30, commentCount: 302),
        .init(writerID: "writerID", writerNickname: "닉네임4", category: .dasi, title: "다시제목4", content: "내용내용2", imagePaths: ["DummyPuppy1"], likeCount: 450, commentCount: 999),
//        .init(writerID: "writerID", writerNickname: "닉네임5", category: .dasi, title: "다시제목5", content: "내용내용1", likeCount: 50, commentCount: 10),
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
