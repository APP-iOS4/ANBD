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
    @Published var detailImages: [Data] = []

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
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            print(error.localizedDescription)
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
    
    func loadOneArticle(articleID: String) async {
        do {
            let loadedArticle = try await articleUseCase.loadArticle(articleID: articleID)
            self.detailImages = try await loadDetailImages(path: .article, containerID: self.article.id, imagePath: self.article.imagePaths)

            self.article = loadedArticle
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    func deleteArticle(article: Article) async {
        do {
            try await articleUseCase.deleteArticle(article: article)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            print(error.localizedDescription)
            print("삭제실패")
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
            await sendLikePushNotification()
        } catch {
            print(error.localizedDescription)
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
            await self.sendCommentPushNotification(content: commentText)
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
            print("댓글 삭제 실패 - \(error.localizedDescription)")
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
            print("Error: \(error)")
        }
    }
    
    //MARK: - PUSH
    
    @MainActor
    func sendCommentPushNotification(content: String) async {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        
        
        guard let serverKey = Bundle.main.firebaseServerKey else {return}
        
        // 게시글 작성자의 토큰
        do {
            let writer = try await userUsecase.getUserInfo(userID: self.article.writerID)
            let user = UserStore.shared.user
            
            guard writer.fcmToken != "" else { return }
            
            let headers = [
                "Authorization": "key=\(serverKey)",
                "Content-Type": "application/json"
            ]
            let body: [String: Any] = [
                "to": writer.fcmToken,
                "notification": [
                    "title": "\(article.title)",
                    "body": "\(user.nickname)님이 댓글을 남겼습니다: \"\(content)\""
                ],
                "content_available" : true
            ]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending push notification: \(error.localizedDescription)")
                }
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "")")
                }
            }.resume()
            
        } catch {
            print(error)
        }
    }
    
    func sendLikePushNotification() async {
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        guard let url = URL(string: urlString) else { return }
        
        guard let serverKey = Bundle.main.firebaseServerKey else {return}
        
        // 게시글 작성자의 토큰
        do {
            let writer = try await userUsecase.getUserInfo(userID: self.article.writerID)
            let user = UserStore.shared.user
            
            guard writer.fcmToken != "" else { return }
            
            let headers = [
                "Authorization": "key=\(serverKey)",
                "Content-Type": "application/json"
            ]
            let body: [String: Any] = [
                "to": writer.fcmToken,
                "notification": [
                    "title": "\(writer.nickname)",
                    "body": "\(user.nickname)님이 회원님의 게시글을 좋아합니다."
                ],
                "content_available" : true
            ]
            
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending push notification: \(error.localizedDescription)")
                }
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "")")
                }
            }.resume()
            
        } catch {
            print(error)
        }
    }
}
