//
//  UserListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct ArticleListView: View {
    @StateObject private var articleListViewModel = ArticleListViewModel()
    @State private var searchArticleText = "" // 검색 텍스트 추적하는 변수
    
    var body: some View {
        VStack {
            TextField("제목이나 ID값으로 검색...", text: $searchArticleText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("제목")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자 닉네임")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("생성일자")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView{
                LazyVStack {
                    ForEach(articleListViewModel.articleList.filter({ searchArticleText.isEmpty ? true : $0.title.contains(searchArticleText) || $0.id.contains(searchArticleText) }), id: \.id) { article in
                        NavigationLink(destination: ArticleListDetailView(article: article, deletedArticleID: $articleListViewModel.deletedArticleID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(article.title)")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(article.writerNickname)")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(dateFormatter(article.createdAt))")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .onAppear {
                    articleListViewModel.loadArticles()
                }
                .navigationBarTitle("게시물 목록")
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}

