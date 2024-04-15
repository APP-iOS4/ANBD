//
//  UserDetailsView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct UserListDetailView: View {
    @State private var userArticleList: [Article] = []
    @State private var userTradeList: [Trade] = []
    @State private var userLikeArticleList: [Article] = []
    @State private var userLikeTradeList: [Article] = []
    let articleUsecase = DefaultArticleUsecase()
    let tradeUsecase = DefaultTradeUsecase()
    let user: User
    
    var body: some View {
        List {
            if let imageUrl = URL(string: user.profileImage) {
                Text("프로필 이미지:").foregroundColor(.gray)
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable().frame(width: 200, height: 200)
                    case .failure:
                        Text("Failed to load image")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            Text("ID:").foregroundColor(.gray) + Text(" \(user.id)")
            Text("닉네임:").foregroundColor(.gray) + Text(" \(user.nickname)")
            Text("이메일:").foregroundColor(.gray) + Text(" \(user.email)")
            Text("선호 지역:").foregroundColor(.gray) + Text(" \(user.favoriteLocation)")
            Text("유저 레벨:").foregroundColor(.gray) + Text(" \(user.userLevel)")
            Text("14세 이상:").foregroundColor(.gray) + Text(" \(user.isOlderThanFourteen ? "예" : "아니오")")
            Text("서비스 이용약관 동의:").foregroundColor(.gray) + Text(" \(user.isAgreeService ? "예" : "아니오")")
            Text("개인정보 수집 동의:").foregroundColor(.gray) + Text(" \(user.isAgreeCollectInfo ? "예" : "아니오")")
            Text("광고 및 마케팅 수신 동의:").foregroundColor(.gray) + Text(" \(user.isAgreeMarketing ? "예" : "아니오")")
            Text("작성한 게시글 목록:").foregroundColor(.gray) + Text(" \n \(userArticleList.map { "\($0.title), \(dateFormatter($0.createdAt)), \($0.id)" }.joined(separator: ", \n "))")
            Text("작성한 거래글 목록:").foregroundColor(.gray) + Text(" \n \(userTradeList.map { "\($0.title), \(dateFormatter($0.createdAt)), \($0.id)" }.joined(separator: ", \n "))")
            Text("좋아요한 게시글 목록:").foregroundColor(.gray) + Text(" \n \(userLikeArticleList.map { "\($0.title), \(dateFormatter($0.createdAt)), \($0.id)" }.joined(separator: ", \n "))")
            Text("찜한 거래글 목록:").foregroundColor(.gray) + Text(" \n \(user.likeTrades.joined(separator: ", \n "))")
        }
        .onAppear {
            Task {
                do {
                    self.userArticleList = try await articleUsecase.loadArticleList(writerID: user.id)
                    self.userTradeList = try await tradeUsecase.loadTradeList(writerID: user.id)
                    self.userLikeArticleList = try await withThrowingTaskGroup(of: Article.self) { group in
                        for articleID in user.likeArticles {
                            group.addTask {
                                try await articleUsecase.loadArticle(articleID: articleID)
                            }
                        }
                        var articles: [Article] = []
                        for try await article in group {
                            articles.append(article)
                        }
                        return articles
                    }
                } catch {
                    print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
        .navigationBarTitle(user.nickname)
    }
}
