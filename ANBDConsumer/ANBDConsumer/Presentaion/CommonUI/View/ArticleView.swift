//
//  ArticleView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/6/24.
//

import SwiftUI
import ANBDModel

struct ArticleView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    
    @State private var isShowingArticleCreateView: Bool = false
    @State private var isShowingTradeCreateView: Bool = false
    @Binding var category: ANBDCategory
    //true - accua, dasi / false - nanua, baccua
    @State private var isArticle: Bool = true
    
    var body: some View {
        if #available(iOS 17.0, *) {
            listView
                .onChange(of: category) {
                    if isArticle {
                        articleViewModel.updateArticles(category: category)
                        
                    } else {
                        tradeViewModel.filteringTrades(category: category)
                    }
                }
                .onAppear {
                    Task {
                        await articleViewModel.loadArticle(category: category)
                    }
                }
        } else {
            listView
                .onChange(of: category, perform: { _ in
                    if isArticle {
                        articleViewModel.updateArticles(category: category)
                    } else {
                        tradeViewModel.filteringTrades(category: category)
                    }
                })
                .onAppear {
                    Task {
                        await articleViewModel.loadArticle(category: category)
                    }
                }
        }
    }
    
    //MARK: - article 서브뷰
    private var listView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 45)
                
                TabView(selection: $category) {
                    if isArticle {
                        ArticleListView(category: .accua, isArticle: isArticle)
                            .tag(ANBDCategory.accua)
                        ArticleListView(category: .dasi, isArticle: isArticle)
                            .tag(ANBDCategory.dasi)
                    } else {
                        ArticleListView(category: .nanua, isArticle: isArticle)
                            .tag(ANBDCategory.nanua)
                        ArticleListView(category: .baccua, isArticle: isArticle)
                            .tag(ANBDCategory.baccua)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button {
                if isArticle {
                    self.isShowingArticleCreateView.toggle()
                } else {
                    self.isShowingTradeCreateView.toggle()
                }
            } label: {
                WriteButtonView()
            }
        }
        .onAppear {
            if category == .accua || category == .dasi {
                isArticle = true
            } else {
                isArticle = false
            }
            
            if isArticle {
                Task {
                    await articleViewModel.loadArticle(category: category)
                }
            } else {
                tradeViewModel.filteringTrades(category: category)
            }
        }
        .onDisappear {
            tradeViewModel.selectedLocations = []
            tradeViewModel.selectedItemCategories = []
        }
        .navigationTitle(isArticle ? "정보 공유" : "나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: "") {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingArticleCreateView, content: {
            ArticleCreateView(isShowingCreateView: $isShowingArticleCreateView, category: category, isNewArticle: true)
        })
        .fullScreenCover(isPresented: $isShowingTradeCreateView, content: {
            TradeCreateView(isShowingCreate: $isShowingTradeCreateView, category: category, isNewProduct: true)
        })
    }
}



#Preview {
    ArticleView(category: .constant(.accua))
        .environmentObject(ArticleViewModel())
}

