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
    private let commentUseCase: CommentUsecase = DefaultCommentUsecase()
    private let user = UserStore.shared.user
    
    private let storageManager = StorageManager.shared
    
    @Published var articlePath: NavigationPath = NavigationPath()
    
    @Published private(set) var articles: [Article] = []
    @Published private(set) var filteredArticles: [Article] = []
    
    @Published var article: Article = Article(id: "",
                                              writerID: "",
                                              writerNickname: "",
                                              createdAt: Date(),
                                              category: .accua,
                                              title: "",
                                              content: "",
                                              thumbnailImagePath: "",
                                              imagePaths: [],
                                              likeCount: 0,
                                              commentCount: 0)
    
    @Published private(set) var comments: [Comment] = []
    
    @Published var comment: Comment = Comment(id: "",
                                              articleID: "",
                                              writerID: "",
                                              writerNickname: "",
                                              writerProfileImageURL: "",
                                              createdAt: Date(),
                                              content: "")

    @Published var commentText: String = ""
    
    @Published var sortOption: ArticleOrder = .latest
    
    @Published private(set) var isLiked: Bool = false
    @Published private var isLikedDictionary: [String: Bool] = [:]
    
    init() {
        
    }
    
    func filteringArticles(category: ANBDCategory) {
        filteredArticles = articles.filter({ $0.category == category })
    }
    
//    func getOneArticle(article: Article) {
//        self.article = article
//    }
    
    @MainActor
    func loadAllArticles() async {
        do {
            try await self.articles.append(contentsOf: articleUseCase.loadArticleList(limit: 10))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reloadAllArticles() async {
        do {
            self.articles = try await articleUseCase.refreshAllArticleList(limit: 10)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func refreshSortedArticleList(category: ANBDCategory, by order: ArticleOrder, limit: Int) async {
        do {
            filteredArticles.removeAll()
            
            let newArticles = try await articleUseCase.refreshSortedArticleList(category: category, by: order, limit: limit)
            filteredArticles.append(contentsOf: newArticles)
            
            print(filteredArticles)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadDetailImages(path: StoragePath, containerID: String, imagePath: [String]) async throws -> [Data] {
        var detailImages: [Data] = []
        
        
        for image in imagePath {
            do {
                detailImages.append(
                    try await storageManager.downloadImage(path: path, containerID: containerID, imagePath: image)
                )
            } catch {
                print("이미지 실패요... \(error.localizedDescription)")
                
                //이미지 예외
                let image = UIImage(named: "ANBDWarning")
                let imageData = image?.pngData()
                detailImages.append( imageData ?? Data() )
            }
        }
        return detailImages
    }
    
    func writeArticle(category: ANBDCategory, title: String, content: String, imageDatas: [Data]) async {

        let newArticle = Article(writerID: user.id,
                                 writerNickname: user.nickname,
                                 category: category,
                                 title: title,
                                 content: content,
                                 thumbnailImagePath: "",
                                 imagePaths: [])
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in imageDatas {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
            try await articleUseCase.writeArticle(article: newArticle, imageDatas: newImages)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateArticle(/*category: ANBDCategory, title: String, content: String*/article: Article, imageDatas: [Data]) async {
        
        //        self.article.category = category
        //        self.article.title = title
        //        self.article.content = content
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in imageDatas {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
            try await articleUseCase.updateArticle(article: article, imageDatas: newImages)
            //            article = try await articleUseCase.loadArticle(articleID: article.id)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadArticle(article: Article) async {
        do {
            let loadedArticle = try await articleUseCase.loadArticle(articleID: article.id)
            self.article = loadedArticle
        } catch {
            print(error.localizedDescription)
            print("실패실패실패실패실패")
        }
    }
    
    func searchArticle(keyword: String) async {
        do {
            let loadedArticles = try await articleUseCase.searchArticle(keyword: keyword, limit: 10)
        } catch {
            print("Error: \(error)")
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
        if let isLiked = isLikedDictionary[articleID] {
            isLikedDictionary[articleID] = !isLiked
        } else {
            isLikedDictionary[articleID] = false
        }
        
        do {
            let isLiked = isLikedDictionary[articleID] ?? false
            
            try await articleUseCase.likeArticle(articleID: articleID)
            
            let updatedArticle = try await articleUseCase.loadArticle(articleID: articleID)
            article.likeCount = updatedArticle.likeCount
            
        } catch {
            print("좋아요 실패요.... \(error.localizedDescription)")
        }
    }
    
    func isArticleLiked(articleID: String) -> Bool {
        return isLikedDictionary[articleID] ?? false
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
    
    // MARK: - Comment
    func writeComment(articleID: String, commentText: String) async {
        let newComment = Comment(articleID: articleID,
                                 writerID: user.id,
                                 writerNickname: user.nickname,
                                 writerProfileImageURL: user.profileImage,
                                 content: commentText)
        
        do {
            try await commentUseCase.writeComment(articleID: articleID, comment: newComment)
            await loadCommentList(articleID: articleID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadCommentList(articleID: String) async {
        do {
            let loadedComment = try await commentUseCase.loadCommentList(articleID: articleID)
            self.comments = loadedComment
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateComment(comment: Comment) async {
        do {
            try await commentUseCase.updateComment(comment: comment)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteComment(articleID: String, commentID: String) async {
        do {
            try await commentUseCase.deleteComment(articleID: articleID, commentID: commentID)
            print("articleID: \(article.id), \(articleID)")
            print("commentID: \(comment.id), \(commentID)")
        } catch {
            print(error.localizedDescription)
            print("댓글 삭제 실패")
            print("articleID: \(article.id), \(articleID)")
            print("commentID: \(comment.id), \(commentID)")
        }
    }
    
}
