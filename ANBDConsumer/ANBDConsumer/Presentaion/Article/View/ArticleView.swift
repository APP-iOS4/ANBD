//
//  ArticleView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/6/24.
//

import SwiftUI
import ANBDModel

class DummyArticle {
    var articles: [Article] = []
    
    init() {
        articles = [
            Article(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "아껴제목1", content: "내용내용5", likeCount: 30, commentCount: 50),
            Article(writerID: "writerID", writerNickname: "닉네임2", category: .accua, title: "아껴제목2", content: "내용내용4", likeCount: 50, commentCount: 40),
            Article(writerID: "writerID", writerNickname: "닉네임3", category: .accua, title: "아껴제목3", content: "내용내용3", likeCount: 10, commentCount: 30),
            Article(writerID: "writerID", writerNickname: "닉네임4", category: .accua, title: "아껴제목4", content: "내용내용2", likeCount: 40, commentCount: 20),
            Article(writerID: "writerID", writerNickname: "닉네임5", category: .accua, title: "아껴제목5", content: "내용내용1", likeCount: 20, commentCount: 10),
            Article(writerID: "writerID", writerNickname: "닉네임1", category: .dasi, title: "다시제목1", content: "내용내용5", likeCount: 10, commentCount: 50),
            Article(writerID: "writerID", writerNickname: "닉네임2", category: .dasi, title: "다시제목2", content: "내용내용4", likeCount: 20, commentCount: 40),
            Article(writerID: "writerID", writerNickname: "닉네임3", category: .dasi, title: "다시제목3", content: "내용내용3", likeCount: 30, commentCount: 30),
            Article(writerID: "writerID", writerNickname: "닉네임4", category: .dasi, title: "다시제목4", content: "내용내용2", likeCount: 40, commentCount: 20),
            Article(writerID: "writerID", writerNickname: "닉네임5", category: .dasi, title: "다시제목5", content: "내용내용1", likeCount: 50, commentCount: 10),
        ]
    }
}

struct ArticleView: View {
    
    @State private var isShowingCreateView: Bool = false
    @State var category: ANBDCategory = .accua
    @State private var sortOption: SortOption = .time
    private var articles = DummyArticle().articles
    @State private var filteredArticles: [Article] = []
    
    enum SortOption {
        case time, likes, comments
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading) {
                    CategoryDividerView(category: $category)
                        .frame(height: 45)
                    
                    VStack {
                        Menu {
                            Button {
                                sortOption = .time
                                updateArticles()
                            } label: {
                                Label("최신순", systemImage: sortOption == .time ? "checkmark" : "")
                            }
                            
                            Button {
                                sortOption = .likes
                                updateArticles()
                            } label: {
                                Label("좋아요순", systemImage: sortOption == .likes ? "checkmark" : "")
                            }
                            
                            Button {
                                sortOption = .comments
                                updateArticles()
                            } label: {
                                Label("댓글순", systemImage: sortOption == .comments ? "checkmark" : "")
                            }
                        } label: {
//                            주석들은 chevron 있는 버전...
//                            Text(getSortOptionLabel())
//                                .font(ANBDFont.Caption3)
//                                .foregroundStyle(.black)
//                            Image(systemName: "chevron.down")
                            CapsuleButtonView(text: getSortOptionLabel(), isForFiltering: true)
                        }
//                        .font(ANBDFont.Caption3)
//                        .foregroundStyle(.gray900)
//
                        .frame(width: 100)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 25.0)
//                                .stroke(.gray)
//                                .frame(height: 35)
//                                .foregroundStyle(.clear)
//                        )
                    }
                    .padding()
                    .font(ANBDFont.SubTitle3)
                    
                    TabView(selection: $category) {
                        articleListView
                            .tag(Category.accua)
                        
                        articleListView
                            .tag(Category.dasi)
                        
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea()
                }
                .onAppear {
                    updateArticles()
                }
                .onChange(of: category) {
                    updateArticles()
                }
                
                Button {
                    self.isShowingCreateView.toggle()
                } label: {
                    WriteButtonView()
                        .padding(10)
                }
            }
        }
        .navigationTitle("정보 공유")
        .toolbarTitleDisplayMode(.inline)
//        .fullScreenCover(isPresented: $isShowingCreateView, content: {
//            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: category, isNewArticle: true)
//        })
        .fullScreenCover(isPresented: $isShowingCreateView, content: {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: category, isNewArticle: true)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
    private func updateArticles() {
        switch sortOption {
        case .time:
            if category == .accua {
                filteredArticles = articles.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = articles.filter { $0.category == .dasi }
            }
            break
        case .likes:
            // 좋아요순 정렬
            if category == .accua {
                filteredArticles = articles.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = articles.filter { $0.category == .dasi }
            }
            filteredArticles.sort(by: { $0.likeCount > $1.likeCount })
            break
        case .comments:
            // 댓글순 정렬
            if category == .accua {
                filteredArticles = articles.filter { $0.category == .accua }
            } else if category == .dasi {
                filteredArticles = articles.filter { $0.category == .dasi }
            }
            filteredArticles.sort(by: { $0.commentCount > $1.commentCount })
            break
        }
    }
    
    private func getSortOptionLabel() -> String {
        switch sortOption {
        case .time:
            return "최신순"
        case .likes:
            return "좋아요순"
        case .comments:
            return "댓글순"
        }
    }
}

extension ArticleView {
    var articleListView: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredArticles, id: \.self) { article in
                    NavigationLink(value: article) {
                        ArticleListCell(article: article)
                            .padding(10)
                    }
                    Divider()
                        .padding(.horizontal, 20)
                }
            }
        }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article, category: $category)
        }
    }
}


//#Preview {
//    ArticleView(articles: DummyArticle().articles)
//}

