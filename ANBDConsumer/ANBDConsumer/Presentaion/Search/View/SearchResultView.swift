//
//  SearchResultView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SearchResultView: View {
    
    @State var category: ANBDCategory = .accua
    var searchText: String
    
    @EnvironmentObject var articleViewModel: ArticleViewModel
    @EnvironmentObject var tradeViewModel: TradeViewModel
    
    var body: some View {
        searchResultView
            .onChange(of: category) {
                if category == .accua || category == .dasi {
                    Task {
                        await articleViewModel.searchArticle(keyword: searchText, category: category)
                    }
                } else {
                    Task {
                        await tradeViewModel.searchTrade(keyword: searchText, category: category)
                    }
                }
            }
    }
    
    private var searchResultView: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 40)
                .padding(.horizontal)
            
            TabView(selection: $category) {
                ArticleListView(category: .accua, isSearchView: true, searchText: searchText)
                    .tag(ANBDCategory.accua)
                
                ArticleListView(category: .nanua, isArticle: false, isSearchView: true, searchText: searchText)
                    .tag(ANBDCategory.nanua)
                
                ArticleListView(category: .baccua, isArticle: false, isSearchView: true, searchText: searchText)
                    .tag(ANBDCategory.baccua)
                
                ArticleListView(category: .dasi, isSearchView: true, searchText: searchText)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            Task {
                switch category {
                case .accua, .dasi:
                    await articleViewModel.searchArticle(keyword: searchText, category: category)
                case .nanua, .baccua:
                    await tradeViewModel.searchTrade(keyword: searchText, category: category)
                }
            }
        }
        .navigationTitle(searchText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
    }
}

#Preview {
    NavigationStack {
        SearchResultView(searchText: "헤드셋")
            .environmentObject(ArticleViewModel())
            .environmentObject(TradeViewModel())
    }
}
