//
//  ArticleListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel
import CachedAsyncImage

struct ArticleListView: View {
    @StateObject private var articleListViewModel = ArticleListViewModel()
    @State private var searchArticleText = ""
    
    var body: some View {
        VStack {
            TextField("제목이나 ID값으로 검색...", text: $searchArticleText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onSubmit {
                    if !searchArticleText.isEmpty {
                        Task {
                            await articleListViewModel.searchArticle(articleID: searchArticleText)
                        }
                    }
                }
                .textInputAutocapitalization(.characters)// 항상 대문자로 입력받음
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
                    ForEach(articleListViewModel.articleList, id: \.id) { article in
                        NavigationLink(destination: ArticleListDetailView(article: article, deletedArticleID: $articleListViewModel.deletedArticleID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(article.title)")
                                        .lineLimit(1)
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(article.writerNickname)")
                                        .lineLimit(2)
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(dateFormatter(article.createdAt))")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                        }
                    }
                    if !articleListViewModel.articleList.isEmpty {
                        Text("List End")
                            .foregroundColor(.gray)
                          .onAppear {
                              articleListViewModel.loadMoreArticles()
                          }
                      }
                }
                .onAppear {
                    articleListViewModel.firstLoadArticles()
                }
                .navigationBarTitle("게시글 목록")
                .toolbar {
                    Button(action: {
                        articleListViewModel.articleList = []
                        articleListViewModel.firstLoadArticles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }         
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}

