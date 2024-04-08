//
//  ArticleViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import ANBDModel

final class ArticleViewModel: ObservableObject {
    
    @Published var articleUsecase: ArticleUsecase
    @Published var commentUsecase: CommentUsecase

    @Published var article: Article?
    @Published var comments: [Comment] = []
    
    init(articleUsecase: ArticleUsecase, commentUsecase: CommentUsecase, article: Article? = nil, comments: [Comment]) {
        self.articleUsecase = articleUsecase
        self.commentUsecase = commentUsecase
        self.article = article
        self.comments = comments
    }
    
}
