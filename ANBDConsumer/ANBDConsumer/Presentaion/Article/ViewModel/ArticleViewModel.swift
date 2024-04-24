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
    private let storageManager = StorageManager.shared
    
    @Published private(set) var articles: [Article] = []
    @Published var filteredArticles: [Article] = []
    @Published var article: Article = Article(id: "",
                                              writerID: "",
                                              writerNickname: "DefaultNickname",
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
                                              writerNickname: "DefaultNickname",
                                              writerProfileImageURL: "",
                                              createdAt: Date(),
                                              content: "")

    @Published var commentText: String = ""
    @Published var sortOption: ArticleOrder = .latest
    @Published private(set) var isLiked: Bool = false
    @Published private var isLikedDictionary: [String: Bool] = [:]
    
    func getOneArticle(article: Article) {
        self.article = article
    }
    
    //MARK: - ARTICLE
    
    @MainActor
    func refreshSortedArticleList(category: ANBDCategory) async {
        do {
            self.filteredArticles = try await articleUseCase.refreshSortedArticleList(category: category, by: self.sortOption, limit: 8)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func loadMoreArticles(category: ANBDCategory) async {
        do {
            var newArticles: [Article] = []
            newArticles = try await articleUseCase.loadArticleList(category: category, by: self.sortOption, limit: 5)
            
            for item in newArticles {
                if filteredArticles.contains(item) {
                    print("end")
                } else {
                    filteredArticles.append(contentsOf: newArticles)
                }
            }
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

        let user = UserStore.shared.user
        
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
    
    func deleteArticle(article: Article) async {
        do {
            try await articleUseCase.deleteArticle(article: article)
        } catch {
            print(error.localizedDescription)
            print("삭제실패")
        }
    }
    
    //MARK: - LIKE
    
    func likeArticle(articleID: String) async {
        do {
            try await articleUseCase.likeArticle(articleID: articleID)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleLikeArticle(articleID: String) async {
        if isLikedDictionary[articleID] != nil {
            isLikedDictionary[articleID] = false
        } else {
            isLikedDictionary[articleID] = true
        }
        
        do {
            try await articleUseCase.likeArticle(articleID: articleID)
            
            let updatedArticle = try await articleUseCase.loadArticle(articleID: articleID)
            article.likeCount = updatedArticle.likeCount
            isLiked.toggle()
            print("좋아요: \(isLiked)")
        } catch {
            print("좋아요 실패요.... \(error.localizedDescription)")
        }
    }
    
    func isArticleLiked(articleID: String) -> Bool {
        return isLikedDictionary[articleID] ?? true
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
        
        let user = UserStore.shared.user
        
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
        } catch {
            print(error.localizedDescription)
            print("댓글 삭제 실패")
        }
    }
    
}
