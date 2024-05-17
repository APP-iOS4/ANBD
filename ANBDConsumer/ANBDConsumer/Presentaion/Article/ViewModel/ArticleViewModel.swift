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
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    private let storageManager = StorageManager.shared
    
    @Published var sortOption: ArticleOrder = .latest
    @Published private(set) var articles: [Article] = []
    @Published var filteredArticles: [Article] = []
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
    @Published var detailImages: [URL] = []

    func getOneArticle(article: Article) {
        self.article = article
    }
    
    func filteringArticles(category: ANBDCategory) {
        filteredArticles = articles.filter({ $0.category == category })
    }
    
    //MARK: - ARTICLE
    
    @MainActor
    func refreshSortedArticleList(category: ANBDCategory) async {
        do {
            self.filteredArticles = try await articleUseCase.refreshSortedArticleList(category: category, by: self.sortOption, limit: 8)
        } catch {
            #if DEBUG
            print("refreshSortedArticleList: \(error)")
            #endif
        }
    }
    
    @MainActor
    func loadMoreArticles(category: ANBDCategory) async {
        do {
            var newArticles: [Article] = []
            newArticles = try await articleUseCase.loadArticleList(category: category, by: self.sortOption, limit: 5)
            for item in newArticles {
                if filteredArticles.contains(item) {
                } else {
                    filteredArticles.append(contentsOf: newArticles)
                }
            }
        } catch {
            #if DEBUG
            print("loadMoreArticles: \(error)")
            #endif
        }
    }
    
    func loadDetailImages(path: StoragePath, containerID: String, imagePath: [String]) async throws -> [URL] {
        var detailImages: [URL] = []
        
        for image in imagePath {
            do {
                detailImages.append(
                    try await storageManager.downloadImageToUrl(path: path, containerID: containerID, imagePath: image)
                )
            } catch {
                #if DEBUG
                print("loadDetailImages: \(error)")
                #endif
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
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("writeArticle: \(error)")
            #endif
            guard let error = error as? ArticleError else {
                ToastManager.shared.toast = Toast(style: .error, message: "게시글 작성에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    @MainActor
    func updateArticle(category: ANBDCategory, title: String, content: String, commentCount: Int, addImages: [Data], deletedImagesIndex: [Int]) async {
        
        let user = UserStore.shared.user
        let originCategory = self.article.category
        
        self.article.category = category
        self.article.title = title
        self.article.content = content
        self.article.commentCount = commentCount
        
        //삭제된 이미지
        var deletedImages: [String] = []
        for i in deletedImagesIndex {
            deletedImages.append(self.article.imagePaths[i])
            self.article.imagePaths.remove(at: i)
        }
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in addImages {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
             try await articleUseCase.updateArticle(article: self.article, add: newImages, delete: deletedImages)
            try await userUsecase.updateUserPostCount(user: user, before: originCategory, after: category)
            article = try await articleUseCase.loadArticle(articleID: article.id)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("updateArticle: \(error)")
            #endif
            guard let error = error as? ArticleError else {
                ToastManager.shared.toast = Toast(style: .error, message: "게시글 수정에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    /// homeView에서 사용하는 load article
    func loadArticle(article: Article) async {
        do {
            let loadedArticle = try await articleUseCase.loadArticle(articleID: article.id)
            self.article = loadedArticle
        } catch {
            #if DEBUG
            print("loadArticle: \(error)")
            #endif
        }
    }
    
    func loadCellImageURL(article: Article, path: String) async -> URL {
        do {
            return try await storageManager.downloadImageToUrl(path: .article, containerID: "\(article.id)/thumbnail", imagePath: path)
        } catch {
            print(error.localizedDescription)
            return URL(string: "https://firebasestorage.googleapis.com/v0/b/anbd-project3.appspot.com/o/Profile%2FDefaultUserProfileImage.png?alt=media&token=fc0e56d9-6855-4ead-ab28-d8ff789799b3")!
        }
    }
    
    /// articleDetail, create view에서 사용하는 load article
    func loadOneArticle(articleID: String) async {
        do {
            let loadedArticle = try await articleUseCase.loadArticle(articleID: articleID)
            self.detailImages = try await loadDetailImages(path: .article, containerID: self.article.id, imagePath: self.article.imagePaths)

            self.article = loadedArticle
        } catch {
            #if DEBUG
            print("loadOneArticle: \(error)")
            #endif
        }
    }
    
    func deleteArticle(article: Article) async {
        do {
            try await articleUseCase.deleteArticle(article: article)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("deleteArticle: \(error)")
            #endif
            guard let error = error as? ArticleError else {
                ToastManager.shared.toast = Toast(style: .error, message: "게시글 삭제에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
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
    
    //MARK: - LIKE
    
    func likeArticle(article: Article) async {
        do {
            try await articleUseCase.likeArticle(articleID: article.id)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("likeArticle: \(error)")
            #endif
            guard let error = error as? ArticleError else {
                ToastManager.shared.toast = Toast(style: .error, message: "게시글 좋아요에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
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
            #if DEBUG
            print("writeComment: \(error)")
            #endif
            guard let error = error as? CommentError else {
                ToastManager.shared.toast = Toast(style: .error, message: "댓글 작성에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func loadCommentList(articleID: String) async {
        do {
            let loadedComment = try await commentUseCase.loadCommentList(articleID: articleID)
            self.comments = loadedComment
        } catch {
            #if DEBUG
            print("loadCommentList: \(error)")
            #endif
        }
    }
    
    func updateComment(comment: Comment) async {
        do {
            try await commentUseCase.updateComment(comment: comment)
        } catch {
            #if DEBUG
            print("updateComment: \(error)")
            #endif
            guard let error = error as? CommentError else {
                ToastManager.shared.toast = Toast(style: .error, message: "댓글 수정에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func deleteComment(articleID: String, commentID: String) async {
        do {
            try await commentUseCase.deleteComment(articleID: articleID, commentID: commentID)
        } catch {
            #if DEBUG
            print("deleteComment: \(error)")
            #endif
            guard let error = error as? CommentError else {
                ToastManager.shared.toast = Toast(style: .error, message: "댓글 삭제에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    //MARK: - SEARCH
    
    func searchArticle(keyword: String, category: ANBDCategory?) async {
        do {
            articles = try await articleUseCase.refreshSearchArticleList(keyword: keyword, limit: 100)
            if let category {
                filteringArticles(category: category)
            }
        } catch {
            #if DEBUG
            print("searchArticle: \(error)")
            #endif
        }
    }
}
