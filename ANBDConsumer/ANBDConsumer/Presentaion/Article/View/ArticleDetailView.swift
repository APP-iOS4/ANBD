//
//  ArticleDetailView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct ArticleDetailView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @StateObject private var coordinator = Coordinator.shared
    
    private var article: Article
    private let user = UserStore.shared.user
    private var articleID: String?
    
    @State private var isLiked: Bool = false
    @State private var isShowingComment: Bool = false
    @State private var commentText: String = ""
    
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingArticleCreateView: Bool = false
    @State private var isShowingArticleConfirmSheet: Bool = false
    @State private var isShowingCustomAlertArticle: Bool = false
    @State private var isShowingCustomAlertComment: Bool = false
    @State private var isShowingCommentEditView: Bool = false
    @State private var isShowingUserBlockAlertView: Bool = false
    @State private var idx: Int = 0
    
    @State private var writerUser: User?
    @State private var commentUser: User?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    init(article: Article, articleID: String?) {
        self.article = article
        self.articleID = articleID
    }
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        // MARK: - 게시글
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    if let writerUser {
                                        if writerUser.id == "abcd1234" {
                                            Image("DefaultUserProfileImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 33, height: 33)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray100, lineWidth: 1)
                                                )
                                        } else {
                                            KFImage(URL(string: writerUser.profileImage))
                                                .placeholder({ _ in
                                                    ProgressView()
                                                })
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 33, height: 33)
                                                .clipShape(.circle)
                                                .onTapGesture {
                                                    coordinator.user = writerUser
                                                    switch coordinator.selectedTab {
                                                    case .home, .article, .trade, .chat:
                                                        if coordinator.isFromUserPage {
                                                            coordinator.pop(2)
                                                            coordinator.isFromUserPage = false
                                                        } else {
                                                            coordinator.appendPath(.userPageView)
                                                        }
                                                        coordinator.isFromUserPage.toggle()
                                                    case .mypage:
                                                        coordinator.pop(coordinator.mypagePath.count)
                                                    }
                                                }
                                        }
                                    } else {
                                        ProgressView()
                                            .frame(width: 33, height: 33)
                                    }
                                    
                                    Text("\(articleViewModel.article.writerNickname)")
                                        .font(ANBDFont.SubTitle3)
                                        .foregroundStyle(.gray900)
                                    
                                    Text("\(articleViewModel.article.createdAt.relativeTimeNamed)")
                                        .font(ANBDFont.Caption1)
                                        .foregroundStyle(.gray400)
                                }
                                .padding(.vertical ,-5)
                                
                                Divider()
                                    .padding(.top, 10)
                                
                                Text("\(articleViewModel.article.title)")
                                    .font(ANBDFont.pretendardSemiBold(26))
                                    .padding(.bottom, 13)
                                
                                Text("\(articleViewModel.article.content)")
                                    .font(ANBDFont.body1)
                                
                                ForEach(0..<articleViewModel.detailImages.count, id: \.self) { i in
                                    let url = articleViewModel.detailImages[i]
                                    
                                    KFImage(url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .onTapGesture {
                                            isShowingImageDetailView.toggle()
                                            idx = i
                                        }
                                        .onAppear {
                                            coordinator.isLoading = false
                                        }
                                        .padding(.top, 3)
                                }
                                
                                if coordinator.isLoading {
                                    HStack {
                                        Spacer()
                                        VStack(alignment: .center) {
                                            ProgressView()
                                            Text("Loading")
                                                .font(ANBDFont.body1)
                                                .foregroundStyle(.gray900)
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.top, 200)
                                        .padding(.bottom, 250)
                                        Spacer()
                                    }
                                }
                                
                                HStack {
                                    Button {
                                        Task {
                                            await articleViewModel.likeArticle(article: article)
                                            await articleViewModel.loadOneArticle(articleID: article.id)
                                        }
                                        isLiked.toggle()
                                    } label: {
                                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundStyle(isLiked ? .accent : .gray900)
                                            .padding(.leading, 10)
                                    }
                                    
                                    Text("\(articleViewModel.article.likeCount)")
                                        .foregroundStyle(.gray900)
                                        .font(ANBDFont.pretendardRegular(12))
                                        .padding(.trailing, 10)
                                        .padding(.top, 2)
                                }
                                .id("댓글 목록")
                                .padding(.top, 10)
                            }
                            .padding(10)
                            Spacer()
                        }
                        .padding(.leading, 10)
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // MARK: - 댓글
                        VStack(alignment: .leading) {
                            if articleViewModel.comments.isEmpty {
                                Text("아직 댓글이 없습니다.\n가장 먼저 댓글을 남겨보세요.")
                                    .font(ANBDFont.SubTitle2)
                                    .foregroundStyle(.gray300)
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, 100)
                                
                            } else {
                                Text("댓글 \(articleViewModel.comments.count)")
                                    .font(ANBDFont.SubTitle3)
                                    .padding(.bottom)
                                    .padding(.leading, 5)
                                
                                ForEach(articleViewModel.comments.reversed()) { comment in
                                    HStack(alignment: .top) {
                                        if comment.writerNickname == "탈퇴한 사용자" {
                                            Image("DefaultUserProfileImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 33, height: 33)
                                                .clipShape(Circle())
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray100, lineWidth: 1)
                                                )
                                        } else {
                                            KFImage(URL(string: comment.writerProfileImageURL))
                                                .placeholder({ _ in
                                                    ProgressView()
                                                })
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40)
                                                .clipShape(.circle)
                                                .onTapGesture {
                                                    Task {
                                                        commentUser = await myPageViewModel.getUserInfo(userID: comment.writerID)
                                                        coordinator.user = commentUser
                                                        switch coordinator.selectedTab {
                                                        case .home, .article, .trade, .chat:
                                                            coordinator.appendPath(.userPageView)
                                                        case .mypage:
                                                            coordinator.pop()
                                                        }
                                                    }
                                                }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("\(comment.writerNickname)")
                                                    .font(ANBDFont.SubTitle3)
                                                
                                                Text("\(comment.createdAt.relativeTimeNamed)")
                                                    .font(ANBDFont.Caption1)
                                                    .foregroundStyle(.gray400)
                                            }
                                            
                                            Text("\(comment.content)")
                                                .font(ANBDFont.Caption3)
                                                .frame(maxHeight: .infinity)
                                        }
                                        .foregroundStyle(.gray900)
                                        
                                        Spacer()
                                        
                                        Menu {
                                            if comment.writerID == UserStore.shared.user.id {
                                                Button {
                                                    articleViewModel.comment = comment
                                                    isShowingCommentEditView.toggle()
                                                } label: {
                                                    Label("수정하기", systemImage: "square.and.pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    articleViewModel.comment = comment
                                                    isShowingCustomAlertComment.toggle()
                                                } label: {
                                                    Label("삭제하기", systemImage: "trash")
                                                }
                                            } else {
                                                Button(role: .destructive) {
                                                    coordinator.reportType = .comment
                                                    coordinator.reportedObjectID = comment.id
                                                    coordinator.appendPath(.reportView)
                                                } label: {
                                                    Label("댓글 신고하기", systemImage: "exclamationmark.bubble")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .font(ANBDFont.pretendardRegular(13))
                                                .rotationEffect(.degrees(90))
                                                .foregroundStyle(.gray900)
                                                .padding(5)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 20)
                                    
                                }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                    }
                }
                .onTapGesture {
                    endTextEditing()
                }
                
                // MARK: - 댓글 입력 부분
                if #available(iOS 17.0, *) {
                    commentTextView
                        .onChange(of: commentText) {
                            if commentText.count > 800 {
                                commentText = String(commentText.prefix(800))
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 1)) {
                                proxy.scrollTo("댓글 목록", anchor: .top)
                            }
                        }
                } else {
                    commentTextView
                        .onChange(of: commentText) { _ in
                            if commentText.count > 800 {
                                commentText = String(commentText.prefix(800))
                            }
                        }
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 1)) {
                                proxy.scrollTo("댓글 목록", anchor: .top)
                            }
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if article.writerID == UserStore.shared.user.id {
                            Button {
                                isShowingArticleCreateView.toggle()
                                Task {
                                    await articleViewModel.loadOneArticle(articleID: articleViewModel.article.id)
                                }
                            } label: {
                                Label("수정하기", systemImage: "square.and.pencil")
                            }
                            
                            Button(role: .destructive) {
                                isShowingCustomAlertArticle.toggle()
                            } label: {
                                Label("삭제하기", systemImage: "trash")
                            }
                        } else {
                            if let writerUser {
                                if writerUser.id != "abcd1234" {
                                    Button(role: .destructive) {
                                        isShowingUserBlockAlertView.toggle()
                                        ToastManager.shared.toast = Toast(style: .success, message: "\(articleViewModel.article.writerNickname)님을 차단했습니다.")
                                    } label: {
                                        Label("사용자 차단하기", systemImage: "person.slash")
                                    }
                                }
                            }
                            
                            Button(role: .destructive) {
                                coordinator.reportType = .article
                                coordinator.reportedObjectID = article.id
                                coordinator.appendPath(.reportView)
                            } label: {
                                Label("게시글 신고하기", systemImage: "exclamationmark.bubble")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(ANBDFont.pretendardRegular(13))
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray900)
                    }
                }
            }
            .onDisappear {
                articleViewModel.detailImages = []
            }
            
            .onAppear {
                Task {
                    coordinator.isLoading = true
                    if let articleID {
                        await articleViewModel.loadOneArticle(articleID: articleID)
                    } else {
                        articleViewModel.getOneArticle(article: article)
                    }
                    
                    isLiked = user.likeArticles.contains(articleViewModel.article.id)
                    
                    articleViewModel.detailImages = try await articleViewModel.loadDetailImagesURL(path: .article, containerID: articleViewModel.article.id, imagePath: articleViewModel.article.imagePaths)
                    articleViewModel.detailImagesData = try await articleViewModel.loadDetailImages(path: .article, containerID: articleViewModel.article.id, imagePath: articleViewModel.article.imagePaths)
                    await articleViewModel.loadCommentList(articleID: article.id)
                    writerUser = await myPageViewModel.getUserInfo(userID: article.writerID)
                    
                }
            }
            .fullScreenCover(isPresented: $isShowingArticleCreateView) {
                ArticleCreateView(isShowingCreateView: $isShowingArticleCreateView, category: article.category, commentCount: articleViewModel.comments.count, isNewArticle: false, article: articleViewModel.article)
            }
            .fullScreenCover(isPresented: $isShowingImageDetailView) {
                ImageDetailView(isShowingImageDetailView: $isShowingImageDetailView, images: $articleViewModel.detailImagesData, idx: $idx)
            }
            .fullScreenCover(isPresented: $isShowingCommentEditView) {
                CommentEditView(isShowingCommentEditView: $isShowingCommentEditView, comment: articleViewModel.comment, isEditComment: false)
            }
            .navigationTitle(navigationTitleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
            
            if isShowingCustomAlertArticle {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertArticle, viewType: .articleDelete) {
                    Task {
                        await articleViewModel.deleteArticle(article: article)
                        await articleViewModel.refreshSortedArticleList(category: article.category)
                        dismiss()
                    }
                }
                
            } else if isShowingCustomAlertComment {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertComment, viewType: .commentDelete) {
                    Task {
                        await articleViewModel.deleteComment(articleID: article.id, commentID: articleViewModel.comment.id)
                        await articleViewModel.loadCommentList(articleID: article.id)
                    }
                }
            } else if isShowingUserBlockAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingUserBlockAlertView, viewType: .userBlocked) {
                    Task {
                        await articleViewModel.blockUser(userID: UserStore.shared.user.id, blockUserID: articleViewModel.article.writerID)
                        dismiss()
                    }
                }
            }
        }
    }
    
    var commentTextView: some View {
        VStack {
            if writerUser?.id != "abcd1234" {
                HStack {
                    let trimmedCommentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    TextField("댓글을 입력해주세요.", text: $commentText, axis: .vertical)
                        .font(ANBDFont.Caption3)
                        .lineLimit(3, reservesSpace: false)
                        .keyboardType(.twitter)
                        .padding(13)
                        .background {
                            Rectangle()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .foregroundStyle(colorScheme == .dark ? .gray700 : .gray100)
                        }
                    
                        .padding(.vertical, 5)
                    Button {
                        if !trimmedCommentText.isEmpty {
                            Task {
                                await articleViewModel.writeComment(articleID: article.id, commentText: trimmedCommentText)
                                commentText = ""
                            }
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(ANBDFont.pretendardSemiBold(28))
                            .rotationEffect(.degrees(45))
                            .padding(.trailing, 4)
                            .foregroundStyle(commentText.isEmpty || trimmedCommentText.isEmpty ? (colorScheme == .dark ? .gray600 : .gray300) : .accent)
                    }
                    .disabled(commentText.isEmpty || trimmedCommentText.isEmpty)
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
                .background(colorScheme == .dark ? .gray50 : .white)
            } else {
                Text("이 게시글에는 댓글을 작성할 수 없습니다.")
                    .font(ANBDFont.SubTitle1)
                    .foregroundColor(.gray300)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var navigationTitleText: String {
        switch article.category {
        case .accua:
            return "아껴쓰기"
        case .dasi:
            return "다시쓰기"
        default:
            return "정보 공유"
        }
    }
}
