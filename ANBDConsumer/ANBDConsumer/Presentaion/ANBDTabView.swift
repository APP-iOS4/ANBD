//
//  ContentView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct ANBDTabView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    var body: some View {
        TabView {
            /// Home
            NavigationStack(path: $homeViewModel.homePath) {
                HomeView()
                    .navigationDestination(for: ANBDCategory.self) { category in
                        switch category {
                        case .accua, .dasi:
                            ArticleListView(category: category, isFromHomeView: true)
                                .onAppear {
                                    articleViewModel.updateArticles(category: category)
                                }
                            
                        case .nanua, .baccua:
                            TradeListView(category: category, isFromHomeView: true)
                                .onAppear {
                                    tradeViewModel.filteringTrades(category: category)
                                }
                        }
                    }
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                    }
                    .navigationDestination(for: String.self) { str in
                        if str == "" {
                            SearchView()
                        } else {
                            SearchResultView(category: .accua, searchText: str)
                        }
                    }
            }
            .tabItem {
                Label("홈", systemImage: "house")
            }
            
            /// Article (정보 공유)
            NavigationStack {
                ArticleView()
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
            }
            .tabItem {
                Label("정보 공유", systemImage: "leaf")
            }
            
            /// Trade (나눔 · 거래)
            NavigationStack {
                TradeView()
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                    }
            }
            .tabItem {
                Label("나눔·거래", systemImage: "arrow.3.trianglepath")
            }
            
            /// Chat
            NavigationStack {
                ChatView()
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.right")
            }
            
            /// Mypage
            NavigationStack(path: $myPageViewModel.myPageNaviPath) {
                UserPageView(isSignedInUser: true)
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                            .toolbarRole(.editor)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                            .toolbarRole(.editor)
                    }
                    .navigationDestination(for: ANBDCategory.self) { category in
                        UserActivityListView(category: category, user: myPageViewModel.user)
                            .toolbarRole(.editor)
                    }
                    .navigationDestination(for: MyPageViewModel.MyPageNaviPaths.self) { path in
                        switch path {
                        case .userLikedArticleList:
                            UserLikedContentsView(category: .accua)
                                .toolbarRole(.editor)
                                .toolbar(.hidden, for: .tabBar)
                        case .userHeartedTradeList:
                            UserLikedContentsView(category: .nanua)
                                .toolbarRole(.editor)
                                .toolbar(.hidden, for: .tabBar)
                        case .accountManagement:
                            AccountManagementView()
                                .toolbarRole(.editor)
                                .toolbar(.hidden, for: .tabBar)
                        }
                    }
            }
            .tabItem {
                Label("내 정보", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    ANBDTabView()
        .environmentObject(HomeViewModel())
        .environmentObject(TradeViewModel())
        .environmentObject(ArticleViewModel())
        .environmentObject(MyPageViewModel())
}
