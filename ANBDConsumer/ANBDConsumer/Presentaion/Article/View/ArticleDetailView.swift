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
    
    var article: Article
    var comment: Comment
    @State private var isLiked: Bool = false
    @State private var isWriter: Bool = true
    
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
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Button {
                                    isGoingToProfileView.toggle()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray100)
                                            .frame(width: 40)
                                        
                                        Text("🐳")
                                            .font(.system(size: 25))
                                    }
                                    .padding(.horizontal, 5)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("\(article.writerNickname)")
                                        .font(ANBDFont.SubTitle3)
                                    
                                    Text("5분 전")
                                        .font(ANBDFont.Caption1)
                                        .foregroundStyle(.gray400)
                                }
                            }
                            .navigationDestination(isPresented: $isGoingToProfileView) {
                                //                                UserPageView(isSignedInUser: false)
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
                                        isLiked.toggle()
                                        await articleViewModel.updateLikeCount(articleID: article.id, increment: isLiked)
                                    }
                                } label: {
                                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(isLiked ? .accent : .gray900)
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
                                    Button {
                                        isGoingToProfileView.toggle()
                                    } label: {
                                        Image("\(comment.writerProfileImageURL)")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .scaledToFill()
                                            .clipShape(Circle())
                                        /*
                                         ZStack {
                                         Circle()
                                         .fill(Color.gray100)
                                         .frame(width: 40)
                                         
                                         Text("🐳")
                                         .font(.system(size: 25))
                                         }
                                         */
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
                                            // 본인 댓글 = 수정, 삭제 | 다른 사람 게시물 = 신고
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
                                        ReportView(reportViewType: .users, reportedObjectID: "")
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
                    //                    Task {
                    //                        await articleViewModel.deleteComment(articleID: article.id, commentID: comment.id)
                    //                        await articleViewModel.loadArticle(article: article)
                    //                    }
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
                            await articleViewModel.writeComment(articleID: article.id, content: commentText)
                            await articleViewModel.loadCommentList(articleID: article.id)
                        }
                        commentText = ""
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
                    
                    //                    guard let userID = UserDefaultsClient.shared.userInfo.id else {
                    
                    //                    }
                    
                    if article.writerID == UserStore.shared.user.id {
                        // 본인 게시물 = 수정, 삭제 | 다른 사람 게시물 = 신고
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
                    //                }
                    //                Button {
                    //                    isShowingArticleConfirmSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
        //        .confirmationDialog("", isPresented: $isShowingArticleConfirmSheet) {
        //        }
        .onAppear {
            Task {
                imageData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
                await articleViewModel.loadCommentList(articleID: article.id)
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateView) {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, isNewArticle: false, article: article)
        }
        //        .fullScreenCover(isPresented: $isShowingCreateView, onDismiss: {
        //            Task {
        //                await articleViewModel.loadArticle(article: article)
        //                imageData = try await articleViewModel.loadDetailImages(path: .article, containerID: article.id, imagePath: article.imagePaths)
        //            }
        //        }) {
        //            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, isNewArticle: false, article: article)
        //        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(detailImage: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .fullScreenCover(isPresented: $isShowingCommentEditView) {
            CommentEditView(isShowingCommentEditView: $isShowingCommentEditView, comment: comment)
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
