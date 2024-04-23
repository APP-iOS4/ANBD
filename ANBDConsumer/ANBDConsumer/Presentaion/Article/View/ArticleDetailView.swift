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

    private var article: Article
    private let user = UserStore.shared.user

    @State private var isShowingComment: Bool = false
    @State private var commentText: String = ""
    
    @State private var isShowingImageDetailView: Bool = false
    @State private var isShowingCreateView: Bool = false
    @State private var isGoingToReportView: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingArticleConfirmSheet: Bool = false
    @State private var isShowingCustomAlertArticle: Bool = false
    @State private var isShowingCustomAlertComment: Bool = false
    @State private var isShowingCommentEditView: Bool = false
    
    
    @State private var detailImage: Image = Image("DummyPuppy1")
    @State private var imageData: [Data] = []
    
    /*
     User 네비 관련 주석
     @State private var writerUser: User?
     @State private var commentUser: User?
     */
    
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
                                /*
                                 User 네비 관련 주석
                                 NavigationLink(value: writerUser) {
                                 Image(writerUser?.profileImage ?? "DummyImage1")
                                 Image(.defaultUserProfile)
                                 .resizable()
                                 .frame(width: 40, height: 40)
                                 .scaledToFill()
                                 .clipShape(Circle())
                                 }
                                 */
                                VStack(alignment: .leading) {
                                    Text("\(article.writerNickname)")
                                        .font(ANBDFont.SubTitle3)
                                    
                                    Text("\(article.createdAt.relativeTimeNamed)")
                                        .font(ANBDFont.Caption1)
                                        .foregroundStyle(.gray400)
                                }
                            }
                            .padding(.bottom, 20)
                            
                            Text("\(article.title)")
                                .font(ANBDFont.pretendardBold(24))
                                .padding(.bottom, 10)
                            
                            Text("\(article.content)")
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
                                        await articleViewModel.toggleLikeArticle(articleID: article.id)
                                        await articleViewModel.updateLikeCount(articleID: article.id, increment: articleViewModel.isArticleLiked(articleID: article.id))
                                    }
                                } label: {
                                    Image(systemName: articleViewModel.isArticleLiked(articleID: article.id) ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(articleViewModel.isArticleLiked(articleID: article.id) ? .accent : .gray900)
                                        .padding(.leading, 10)
                                }
                                Text("\(article.likeCount)")
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
                                    /*
                                     User 네비 관련 주석
                                     NavigationLink(value: commentUser) {
                                     Image(writerUser?.profileImage ?? "DummyImage1")
                                     Image(.defaultUserProfile)
                                     .resizable()
                                     .frame(width: 40, height: 40)
                                     .scaledToFill()
                                     .clipShape(Circle())
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
                                            } label: {
                                                Label("수정하기", systemImage: "square.and.pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                isShowingCustomAlertComment.toggle()
                                            } label: {
                                                Label("삭제하기", systemImage: "trash")
                                            }
                                        } else {
                                            Button(role: .destructive) {
                                                isGoingToReportView.toggle()
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
                                    .navigationDestination(isPresented: $isGoingToReportView) {
                                        ReportView(reportViewType: .article, reportedObjectID: "")
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
                         // MARK: - comment.id를 못 가져오는 중,,
//                         await articleViewModel.deleteComment(articleID: self.article.id, commentID: self.articleViewModel.comment.id)
                     await articleViewModel.loadArticle(article: article)
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
                                await articleViewModel.reloadAllArticles()
                            }
                            isShowingCustomAlertArticle.toggle()
                        } label: {
                            Label("삭제하기", systemImage: "trash")
                        }
                    } else {
                        Button(role: .destructive) {
                            isGoingToReportView.toggle()
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
            // articleViewModel.getOneArticle(article: article)
            Task {
                //                writerUser = await myPageViewMode.getUserInfo(userID: article.writerID)
                //                commentUser = await myPageViewMode.getUserInfo(userID: comment.writerID)
                
                imageData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
                await articleViewModel.loadCommentList(articleID: article.id)
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateView) {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, isNewArticle: false, article: article)
        }
        /*
         수정하고 완료했을 때 로드시키고 싶었는데 실패해서 일단 주석해둠 !
         .fullScreenCover(isPresented: $isShowingCreateView, onDismiss: {
         Task {
         await articleViewModel.loadArticle(article: article)
         imageData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
         }
         }) {
         ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, isNewArticle: false, article: article)
         }
         */
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .fullScreenCover(isPresented: $isShowingCommentEditView) {
            CommentEditView(isShowingCommentEditView: $isShowingCommentEditView, comment: articleViewModel.comment, isNewComment: true)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .article, reportedObjectID: "")
        }
        .navigationTitle("정보 공유")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

//#Preview {
//    ArticleDetailView(article: Article(writerID: "IDID", writerNickname: "닉네임", category: .accua, title: "제목제목", content: "내용", thumbnailImagePath: ""))
//}
