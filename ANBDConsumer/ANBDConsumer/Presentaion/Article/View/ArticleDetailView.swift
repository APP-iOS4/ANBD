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
    @Binding var category: Category

//    @State private var category: Category = .accua
    @State private var isLiked: Bool = false
    @State private var isShowingComment: Bool = false
    @State private var comments: [Comment] = []
    @State private var commentText: String = ""
    @State private var isShowingCreateView = false
    
    struct Comment: Identifiable {
        let id: UUID = UUID()
        let userName: String
        let content: String
    }
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            // 프로필 이동
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
                    .padding(.bottom, 20)
                    
                    Text("\(article.title)")
                        .font(ANBDFont.Heading3)
                        .padding(.bottom , 10)
                    
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
                        } label: {
                            Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .resizable()
                                .frame(width: 25, height: 23)
                                .foregroundStyle(isLiked ? .accent : .gray900)
                                .padding(.leading, 10)
                            
                        }
                        Text("\(article.likeCount)")
                            .font(ANBDFont.body1)
                            .foregroundStyle(.gray900)
                    }
                    .padding(.vertical)
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
                                // 프로필 이동
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
                                        .font(ANBDFont.Caption2)
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
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 13)
                                    .rotationEffect(.degrees(90))
                                    .foregroundStyle(.gray500)
                            }
                            .confirmationDialog("", isPresented: $isShowingComment) {
                                Button {
                                    
                                } label: {
                                    Text("수정하기")
                                }
                                
                                Button(role: .destructive) {
                                    
                                } label: {
                                    Text("삭제하기")
                                }
                                
                                // 본인 댓글 = 수정,삭제 | 다른 사람 댓글 = 신고
                                Button(role: .destructive) {
                                    
                                } label: {
                                    Text("신고하기")
                                }
                            }
                            
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: {
                        isShowingCreateView.toggle()
                    }, label: {
                        Label("수정하기", systemImage: "square.and.pencil")
                    })
                    Button(role: .destructive) {
                        
                    } label: {
                        Label("삭제하기", systemImage: "trash")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingCreateView) {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: category, isNewArticle: false, article: article)
        }
        .navigationTitle("정보 공유")
        .navigationBarTitleDisplayMode(.inline)
        
        HStack {
            ZStack {
                Rectangle()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(height: 43)
                    .foregroundStyle(.gray50)
                TextField("댓글을 입력해주세요.", text: $commentText)
                    .font(ANBDFont.Caption1)
                    .padding(15)
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
        }
        .padding(.horizontal, 10)
        .toolbar(.hidden, for: .tabBar)
    }
}
#Preview {
    ArticleDetailView(article: Article(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "제목제목", content: "내용내용"), category: .constant(.accua))
}
