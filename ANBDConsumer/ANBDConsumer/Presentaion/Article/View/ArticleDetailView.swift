//
//  ArticleDetailView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel

struct ArticleDetailView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var myPageViewMode: MyPageViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    private var article: Article
    private let user = UserStore.shared.user
    
    @State private var isLiked: Bool = false
    @State private var isShowingComment: Bool = false
    @State private var commentText: String = ""
    
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingCreateView: Bool = false
    @State private var isShowingArticleConfirmSheet: Bool = false
    @State private var isShowingCustomAlertArticle: Bool = false
    @State private var isShowingCustomAlertComment: Bool = false
    @State private var isShowingCommentEditView: Bool = false
    
    @State private var detailImage: Image = Image("DummyPuppy1")
    @State private var imageData: [Data] = []
    
    @State private var writerUser: User?
    //    @State private var commentUser: User?
    
    @Environment(\.dismiss) private var dismiss
    
    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    // MARK: - 게시글
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(.defaultUserProfile)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        coordinator.user = writerUser
                                        switch coordinator.selectedTab {
                                        case .home, .article, .trade, .chat:
                                            if coordinator.isFromUserPage {
                                                coordinator.pop(2)
                                            } else {
                                                coordinator.appendPath(.userPageView)
                                            }
                                            coordinator.isFromUserPage.toggle()
                                        case .mypage:
                                            coordinator.pop(coordinator.mypagePath.count)
                                        }
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text("\(articleViewModel.article.writerNickname)")
                                        .font(ANBDFont.SubTitle3)
                                    
                                    Text("\(articleViewModel.article.createdAt.relativeTimeNamed)")
                                        .font(ANBDFont.Caption1)
                                        .foregroundStyle(.gray400)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            Text("\(articleViewModel.article.title)")
                                .font(ANBDFont.pretendardBold(24))
                                .padding(.bottom, 10)
                            
                            Text("\(articleViewModel.article.content)")
                                .font(ANBDFont.body1)
                                .padding(.bottom, 10)
                            
                            ForEach(imageData, id: \.self) { photoData in
                                if let image = UIImage(data: photoData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .onTapGesture {
                                            detailImage = Image(uiImage: image)
                                            isShowingImageDetailView.toggle()
                                        }
                                } else {
                                    ProgressView()
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
                                    .font(.system(size: 12))
                                    .padding(.trailing, 10)
                                    .padding(.top, 2)
                            }
                            .padding(.top, 10)
                        }
                        .padding(10)
                        Spacer()
                    }
                    .padding(.leading, 9)
                    
                    Divider()
                        .padding(.horizontal, 20)
                    
                    // MARK: - 댓글
                    VStack(alignment: .leading) {
                        if articleViewModel.comments.isEmpty {
                            Text("아직 댓글이 없습니다.\n가장 먼저 댓글을 남겨보세요.")
                                .font(ANBDFont.SubTitle2)
                                .foregroundStyle(.gray300)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("댓글 \(articleViewModel.comments.count)")
                                .font(ANBDFont.SubTitle3)
                                .padding(.bottom)
                                .padding(.leading, 5)
                            
                            ForEach(articleViewModel.comments) { comment in
                                HStack(alignment: .top) {
                                    Image(.defaultUserProfile)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .scaledToFill()
                                        .clipShape(Circle())
                                    /*
                                     댓글 프로필 이동 관련
                                     .onTapGesture {
                                     articleViewModel.comment = comment
                                     coordinator.user = commentUser
                                     switch coordinator.selectedTab {
                                     case .home, .article, .trade, .chat:
                                     coordinator.appendPath(.userPageView)
                                     case .mypage:
                                     coordinator.pop()
                                     }
                                     }
                                     */
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
                                                isShowingCommentEditView.toggle()
                                                articleViewModel.comment = comment
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
                                                // TODO: 댓글 신고
                                                coordinator.reportType = .comment
                                            } label: {
                                                Label("신고하기", systemImage: "exclamationmark.bubble")
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 13))
                                            .rotationEffect(.degrees(90))
                                            .foregroundStyle(.gray900)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.bottom, 20)
                            }
                        }
                        Spacer(minLength: 60)
                    }
                    .padding()
                }
            }
            .onTapGesture {
                endTextEditing()
            }
            
            if isShowingCustomAlertArticle {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertArticle, viewType: .articleDelete) {
                    dismiss()
                }
                .zIndex(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else if isShowingCustomAlertComment {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertComment, viewType: .commentDelete) {
                    Task {
                        await articleViewModel.deleteComment(articleID: article.id, commentID: articleViewModel.comment.id)
                        await articleViewModel.loadOneArticle(articleID: article.id)
                    }
                }
                .zIndex(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            VStack {
                Spacer()
                HStack {
                    ZStack {
                        Rectangle()
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .frame(height: 43)
                            .foregroundStyle(.gray50)
                        TextField("댓글을 입력해주세요.", text: $commentText)
                            .font(ANBDFont.Caption3)
                            .padding(20)
                    }
                    Button {
                        Task {
                            await articleViewModel.writeComment(articleID: article.id, commentText: commentText)
                            commentText = ""
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(ANBDFont.pretendardSemiBold(28))
                            .rotationEffect(.degrees(45))
                            .foregroundStyle(commentText.isEmpty ? .gray300 : .accent)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding(.horizontal, 10)
                .toolbar(.hidden, for: .tabBar)
                .background(Color.white)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if article.writerID == UserStore.shared.user.id {
                        Button {
                            isShowingCreateView.toggle()
                        } label: {
                            Label("수정하기", systemImage: "square.and.pencil")
                        }
                        
                        Button(role: .destructive) {
                            Task {
                                await articleViewModel.deleteArticle(article: article)
                                await articleViewModel.refreshSortedArticleList(category: article.category)
                            }
                            isShowingCustomAlertArticle.toggle()
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            coordinator.reportType = .article
                            coordinator.reportedObjectID = article.id
                            coordinator.appendPath(.reportView)
                        } label: {
                            Label("신고하기", systemImage: "exclamationmark.bubble")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
        .onAppear {
            articleViewModel.getOneArticle(article: article)
            isLiked = user.likeArticles.contains(articleViewModel.article.id)
            Task {
                writerUser = await myPageViewMode.getUserInfo(userID: article.writerID)
                // commentUser = await myPageViewMode.getUserInfo(userID: articleViewModel.comment.writerID)
                
                imageData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
                await articleViewModel.loadCommentList(articleID: article.id)
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateView) {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, commentCount: articleViewModel.comments.count, isNewArticle: false, article: article)
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .fullScreenCover(isPresented: $isShowingCommentEditView) {
            CommentEditView(isShowingCommentEditView: $isShowingCommentEditView, comment: articleViewModel.comment, isEditComment: false)
        }
        .navigationTitle("정보 공유")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

//#Preview {
//    ArticleDetailView(article: Article(writerID: "IDID", writerNickname: "닉네임", category: .accua, title: "제목제목", content: "내용", thumbnailImagePath: ""))
//}
