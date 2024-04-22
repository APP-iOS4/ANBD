//
//  UserDetailsView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct UserListDetailView: View {
    @Environment(\.presentationMode) var userLevelEditPresentationMode
    @State private var userArticleList: [Article] = []
    @State private var userTradeList: [Trade] = []
    @State private var userLikeArticleList: [Article] = []
    @State private var userLikeTradeList: [Article] = []
    let articleUsecase = DefaultArticleUsecase()
    let tradeUsecase = DefaultTradeUsecase()
    let userUsecase = DefaultUserUsecase()
    let user: User
    @State private var editingUserLevel = false // 유저 레벨 편집 상태를 추적하는 변수
    @State private var initialUserLevel:UserLevel // 새 유저 레벨을 추적하는 변수
    
    init(user: User, initialUserLevel: UserLevel) {
        self.user = user
        _initialUserLevel = State(initialValue: initialUserLevel)
    }
    
    var body: some View {
        List {
            if let imageUrl = URL(string: user.profileImage) {
                Text("프로필 이미지:").foregroundColor(.gray)
                CachedAsyncImage(url: imageUrl) { phase in
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
            HStack {
                Text("ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.id)")
            }
            HStack {
                Text("닉네임:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.nickname)")
            }
            HStack {
                Text("이메일:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.email)")
            }
            HStack {
                Text("선호 지역:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.favoriteLocation)")
            }
            HStack {
                Text("14세 이상:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.isOlderThanFourteen ? "예" : "아니오")")
            }
            HStack {
                Text("서비스 이용약관 동의:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.isAgreeService ? "예" : "아니오")")
            }
            HStack {
                Text("개인정보 수집 동의:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.isAgreeCollectInfo ? "예" : "아니오")")
            }
            HStack {
                Text("광고 및 마케팅 수신 동의:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.isAgreeMarketing ? "예" : "아니오")")
            }
            HStack {
                Text("작성한 게시글 목록:").foregroundColor(.gray)
                Spacer()
                Text("\(userArticleList.map { "\($0.id),  \(dateFormatter($0.createdAt))" }.joined(separator: ", \n "))")
            }
            HStack {
                Text("작성한 거래글 목록:").foregroundColor(.gray)
                Spacer()
                Text("\(userTradeList.map { "\($0.id),  \(dateFormatter($0.createdAt))" }.joined(separator: ", \n "))")
            }
            HStack {
                Text("좋아요한 게시글 목록:").foregroundColor(.gray)
                Spacer()
                Text("\(userLikeArticleList.map { "\($0.id),  \(dateFormatter($0.createdAt))" }.joined(separator: ", \n "))")
            }
            HStack {
                Text("찜한 거래글 목록:").foregroundColor(.gray)
                Spacer()
                Text(" \n \(user.likeTrades.joined(separator: ", \n "))")
            }
            HStack {
                Text("유저 권한:").foregroundColor(.gray)
                Spacer()
                Text(" \(user.userLevel)")
            }
            if editingUserLevel {
                Picker("Select new user level", selection: $initialUserLevel) {
                    Text("Banned").tag(UserLevel.banned)
                    Text("Consumer").tag(UserLevel.consumer)
                }
                .pickerStyle(.segmented)
                .padding()
                Button("Update User Level") {
                    var updatedUser = user
                    updatedUser.userLevel = initialUserLevel
                    Task {
                        do {
                            try await userUsecase.updateUserInfo(user: updatedUser)
                            editingUserLevel = false
                            userLevelEditPresentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Failed to update user info: \(error)")
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                HStack {
                    Text("userLevel:").foregroundColor(.gray) + Text(" \(user.userLevel.rawValue)")
                    if (user.userLevel == .consumer) || (user.userLevel == .banned) {
                        Button(action: { editingUserLevel = true }) {
                            Text("Edit")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    self.userArticleList = try await articleUsecase.loadArticleList(writerID: user.id, category: nil, limit: 10)
                    self.userTradeList = try await tradeUsecase.loadTradeList(writerID: user.id, category: nil, limit: 10)
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
