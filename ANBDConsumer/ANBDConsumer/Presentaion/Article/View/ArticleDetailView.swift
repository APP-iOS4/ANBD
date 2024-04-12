//
//  ArticleDetailView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel

struct ArticleDetailView: View {
    
    var article: Article
    
    @State private var isLiked: Bool = false
    @State private var isWriter: Bool = true
    
    @State private var isShowingComment: Bool = false
    @State private var comments: [Comment] = []
    @State private var commentText: String = ""
    
    @State private var isShowingCreateView: Bool = false
    @State private var isGoingToReportView: Bool = false
    @State private var isGoingToProfileView: Bool = false
    @State private var isShowingArticleConfirmSheet: Bool = false
    @State private var isShowingCustomAlertArticle: Bool = false
    @State private var isShowingCustomAlertComment: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    struct Comment: Identifiable {
        let id: UUID = UUID()
        let userName: String
        let content: String
    }
    
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
                            
                            Image("DummyImage1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.bottom, 10)
                            
                            HStack {
                                Button {
                                    isLiked.toggle()
                                    // 좋아요 기능 로직 추가 필요
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
                        if comments.isEmpty {
                            Text("아직 댓글이 없습니다.\n가장 먼저 댓글을 남겨보세요.")
                                .font(ANBDFont.SubTitle2)
                                .foregroundStyle(.gray300)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("댓글 \(comments.count)")
                                .font(ANBDFont.SubTitle3)
                                .padding(.bottom)
                                .padding(.leading, 5)
                            
                            ForEach(comments) { comment in
                                HStack(alignment: .top) {
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
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("\(comment.userName)")
                                                .font(ANBDFont.SubTitle3)
                                            
                                            Text("5분 전")
                                                .font(ANBDFont.Caption1)
                                                .foregroundStyle(.gray400)
                                        }
                                        Text("\(comment.content)")
                                            .font(ANBDFont.Caption3)
                                            .frame(maxHeight: .infinity)
                                    }
                                    .foregroundStyle(.gray900)
                                    
                                    Spacer()
                                    Button {
                                        isShowingComment.toggle()
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 13))
                                            .rotationEffect(.degrees(90))
                                            .foregroundStyle(.gray900)
                                    }
                                    .confirmationDialog("", isPresented: $isShowingComment) {
                                        if isWriter {
                                            // 본인 댓글 = 수정, 삭제 | 다른 사람 댓글 = 신고
                                            Button {
                                                // 수정하기 기능 추가
                                            } label: {
                                                Text("수정하기")
                                            }
                                            
                                            Button(role: .destructive) {
                                                isShowingCustomAlertComment.toggle()
                                            } label: {
                                                Text("삭제하기")
                                            }
                                        } else {
                                            Button(role: .destructive) {
                                                isGoingToReportView.toggle()
                                            } label: {
                                                Text("신고하기")
                                            }
                                        }
                                    }
                                    .navigationDestination(isPresented: $isGoingToReportView) {
                                        ReportView(reportViewType: .user)
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
                        let newComment = Comment(userName: "김기표", content: commentText)
                        comments.append(newComment)
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
                Button {
                    isShowingArticleConfirmSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
        .confirmationDialog("", isPresented: $isShowingArticleConfirmSheet) {
            if isWriter {
                // 본인 게시물 = 수정, 삭제 | 다른 사람 게시물 = 신고
                Button {
                    isShowingCreateView.toggle()
                } label: {
                    Text("수정하기")
                }
                
                Button(role: .destructive) {
                    isShowingCustomAlertArticle.toggle()
                } label: {
                    Text("삭제하기")
                }
            } else {
                Button(role: .destructive) {
                    isGoingToReportView.toggle()
                } label: {
                    Text("신고하기")
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateView) {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: article.category, isNewArticle: false, article: article)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .article)
        }
        .navigationTitle("정보 공유")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
    }
}

#Preview {
    ArticleDetailView(article: Article(writerID: "IDID", writerNickname: "닉네임", category: .accua, title: "제목제목", content: "내용"))
}
