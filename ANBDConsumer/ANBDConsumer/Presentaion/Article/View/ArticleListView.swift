//
//  ArticleListView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ArticleListView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    
    @State var category: ANBDCategory = .accua
    var isFromHomeView: Bool = false
    var searchText: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Menu {
                Button {
                    articleViewModel.sortOption = .time
                    articleViewModel.updateArticles(category: category)
                } label: {
                    Label("최신순", systemImage: articleViewModel.sortOption == .time ? "checkmark" : "")
                }
                
                Button {
                    articleViewModel.sortOption = .likes
                    articleViewModel.updateArticles(category: category)
                } label: {
                    Label("좋아요순", systemImage: articleViewModel.sortOption == .likes ? "checkmark" : "")
                }
                
                Button {
                    articleViewModel.sortOption = .comments
                    articleViewModel.updateArticles(category: category)
                } label: {
                    Label("댓글순", systemImage: articleViewModel.sortOption == .comments ? "checkmark" : "")
                }
            } label: {
                CapsuleButtonView(text: articleViewModel.getSortOptionLabel(), isForFiltering: true)
            }
            .frame(width: 100)
            .padding(.leading, 10)
            
            if articleViewModel.filteredArticles.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("해당하는 정보 공유 게시글이 없습니다.")
                            .foregroundStyle(.gray400)
                            .font(ANBDFont.body1)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(articleViewModel.filteredArticles) { article in
                            NavigationLink(value: article) {
                                ArticleListCell(article: article)
                            }
                            .padding(.vertical, 5)
                            Divider()
                        }
                        .padding(.horizontal)
                        
                    }
                    .background(.white)
                    .padding(.bottom, 80)
                }
                .navigationDestination(for: Article.self) { article in
                    ArticleDetailView(article: article)
                }
                .background(.gray50)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isFromHomeView ? .hidden : .visible, for: .tabBar)
        .onAppear {
            articleViewModel.updateArticles(category: category)
        }
        .onChange(of: category) {
            articleViewModel.updateArticles(category: category)
        }
    }
}

extension ArticleListView {
    private var navigationTitle: String {
        if let searchText = searchText {
            return searchText
        } else if isFromHomeView {
            return category.description
        } else {
            return "정보 공유"
        }
    }
}


#Preview {
    ArticleListView()
        .environmentObject(ArticleViewModel())

}
