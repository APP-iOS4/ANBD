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
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @State private var articleCategory: ANBDCategory = .accua
    @State private var tradeCategory: ANBDCategory = .nanua
    
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
                                    Task {
                                        articleViewModel.filteringArticles(category: category)
                                    }
                                }
                            
                        case .nanua, .baccua:
                            ArticleListView(category: category, isArticle: false, isFromHomeView: true)
                                .onAppear {
                                    tradeViewModel.filteringTrades(category: category)
                                }
                        }
                    }
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade, anbdViewType: .home)
                    }
                    .navigationDestination(for: String.self) { str in
                        SearchResultView(category: tradeCategory, searchText: str)
                    }
                    .navigationDestination(for: ANBDNavigationPaths.self) { path in
                        switch path {
                        case .searchView:
                            SearchView()
                        case .chatDetailView:
                            ChatDetailView(trade: homeViewModel.chatDetailTrade, anbdViewType: .home)
                        case .reportView:
                            ReportView(reportViewType: homeViewModel.reportType, reportedObjectID: homeViewModel.reportedObjectID, reportedChannelID: homeViewModel.reportedChannelID)
                        }
                    }
            }
            .tabItem {
                Label("홈", systemImage: "house")
            }
            
            /// Article (정보 공유)
            NavigationStack(path: $articleViewModel.articlePath) {
                ArticleView(category: $articleCategory)
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
                            SearchResultView(category: articleCategory, searchText: str)
                        }
                    }
            }
            .tabItem {
                Label("정보 공유", systemImage: "leaf")
            }
            
            /// Trade (나눔 · 거래)
            NavigationStack(path: $tradeViewModel.tradePath) {
                ArticleView(category: $tradeCategory)
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                    }
                    .navigationDestination(for: String.self) { str in
                        SearchResultView(category: tradeCategory, searchText: str)
                    }
//                    .navigationDestination(for: User.self) { user in
//                        UserPageView(writerUser: user)
//                    }
                    .navigationDestination(for: ANBDCategory.self) { category in
                        UserActivityListView(category: category, user: myPageViewModel.user)
                    }
                    .navigationDestination(for: ANBDNavigationPaths.self) { path in
                        switch path {
                        case .searchView:
                            SearchView()
                        case .chatDetailView:
                            ChatDetailView(trade: homeViewModel.chatDetailTrade, anbdViewType: .trade)
                        case .reportView:
                            ReportView(reportViewType: homeViewModel.reportType, reportedObjectID: homeViewModel.reportedObjectID, reportedChannelID: homeViewModel.reportedChannelID)
                        }
                    }
            }
            .tabItem {
                Label("나눔·거래", systemImage: "arrow.3.trianglepath")
            }
            
            /// Chat
            NavigationStack(path: $chatViewModel.chatPath) {
                ChatView()
                    .navigationDestination(for: Channel.self) { channel in
                        ChatDetailView(channel: channel)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade, anbdViewType: .chat)
                    }
                    .navigationDestination(for: ANBDNavigationPaths.self) { path in
                        if path == .reportView {
                            ReportView(reportViewType: chatViewModel.reportType, reportedObjectID: chatViewModel.reportedObjectID, reportedChannelID: chatViewModel.reportedChannelID)
                        } else if path == .chatDetailView {
                            ChatDetailView(trade: homeViewModel.chatDetailTrade, anbdViewType: .chat)
                        }
                    }
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.right")
            }
            
            /// Mypage
            NavigationStack(path: $myPageViewModel.myPageNaviPath) {
                UserPageView(writerUser: myPageViewModel.user)
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                    }
                    .navigationDestination(for: ANBDCategory.self) { category in
                        UserActivityListView(category: category, user: myPageViewModel.user)
                    }
                    .navigationDestination(for: MyPageViewModel.MyPageNaviPaths.self) { path in
                        switch path {
                        case .userLikedArticleList:
                            UserLikedContentsView(category: .accua)
                        case .userHeartedTradeList:
                            UserLikedContentsView(category: .nanua)
                        case .accountManagement:
                            AccountManagementView()
                        case .report:
                            ReportView(reportViewType: .users, reportedObjectID: "")
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
