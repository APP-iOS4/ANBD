//
//  UserListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ArticleListView: View {
    @StateObject private var articleListViewModel = ArticleListViewModel()
    @State private var searchArticleText = "" // 검색 텍스트 추적하는 변수
    
    var body: some View {
        VStack {
            TextField("검색...", text: $searchArticleText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            List {
                ForEach(articleListViewModel.articleList.filter({ searchArticleText.isEmpty ? true : $0.title.contains(searchArticleText) || $0.id.contains(searchArticleText) }), id: \.id) { article in
                    NavigationLink(destination: ArticleListDetailView(article: article, deletedArticleID: $articleListViewModel.deletedArticleID)) {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("제목")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(article.title)")
                                    .font(.title3)
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("작성자 닉네임")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(article.writerNickname)")
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("생성일자")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(dateFormatter(article.createdAt))")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }
                }
            }    
            .onAppear {
                articleListViewModel.loadArticles()
            }
            .navigationBarTitle("게시물 목록")
        }
    }
}
