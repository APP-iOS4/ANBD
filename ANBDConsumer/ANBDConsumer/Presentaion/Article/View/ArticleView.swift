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
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    
    @State private var isGoingToSearchView: Bool = false
    @State private var isShowingCreateView: Bool = false
    @State var category: ANBDCategory = .accua
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 45)
                
                TabView(selection: $category) {
                    ArticleListView(category: .accua)
                        .tag(ANBDCategory.accua)
                    ArticleListView(category: .dasi)
                        .tag(ANBDCategory.dasi)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button {
                self.isShowingCreateView.toggle()
            } label: {
                WriteButtonView()
            }
        }
        .navigationTitle("정보 공유")
        .toolbarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingCreateView, content: {
            ArticleCreateView(isShowingCreateView: $isShowingCreateView, category: category, isNewArticle: true)
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isGoingToSearchView.toggle()
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                })
            }
        }
        .navigationDestination(isPresented: $isGoingToSearchView) {
            SearchView()
        }
    }
}


#Preview {
    ArticleView(category: .accua)
        .environmentObject(ArticleViewModel())
}

