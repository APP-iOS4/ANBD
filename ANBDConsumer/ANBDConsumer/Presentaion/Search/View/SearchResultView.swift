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
        if #available(iOS 17.0, *) {
            searchResultView
                .onChange(of: category) {
                    if category == .accua || category == .dasi {
                        Task {
                            //articleViewModel.filteringArticles(category: category)
                        }
                    } else {
                        //tradeViewModel.filteringTrades(category: category)
                    }
                }
        } else {
            searchResultView
                .onChange(of: category) { category in
                    if category == .accua || category == .dasi {
                        Task {
                            //articleViewModel.filteringArticles(category: category)
                        }
                    } else {
                        //tradeViewModel.filteringTrades(category: category)
                    }
                }
        }
    }
    
    fileprivate var searchResultView: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 40)
                .padding(.horizontal)
            
            TabView(selection: $category) {
                ArticleListView(category: .accua, searchText: searchText)
                    .tag(ANBDCategory.accua)
                
                ArticleListView(category: .nanua, isArticle: false, searchText: searchText)
                    .tag(ANBDCategory.nanua)
                
                ArticleListView(category: .baccua, isArticle: false, searchText: searchText)
                    .tag(ANBDCategory.baccua)
                
                ArticleListView(category: .dasi, searchText: searchText)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            if category == .accua || category == .dasi {
                Task {
                    //articleViewModel.filteringArticles(category: category)
                }
            } else {
                //tradeViewModel.filteringTrades(category: category)
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
