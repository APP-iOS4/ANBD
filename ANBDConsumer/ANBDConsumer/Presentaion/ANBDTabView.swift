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
    @EnvironmentObject private var coordinator: Coordinator
    
    @State private var articleCategory: ANBDCategory = .accua
    @State private var tradeCategory: ANBDCategory = .nanua
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            /// Home
            NavigationStack(path: $coordinator.homePath) {
                HomeView()
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page)
                    }
            }
            .tabItem {
                Label("홈", systemImage: "house")
            }
            .tag(ANBDTabViewType.home)
            
            
            /// Article (정보 공유)
            NavigationStack(path: $coordinator.articlePath) {
                ArticleView(category: $articleCategory)
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page)
                    }
                    
            }
            .tabItem {
                Label("정보 공유", systemImage: "leaf")
            }
            .tag(ANBDTabViewType.article)
            
            
            /// Trade (나눔 · 거래)
            NavigationStack(path: $coordinator.tradePath) {
                ArticleView(category: $tradeCategory)
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page)
                    }
            }
            .tabItem {
                Label("나눔·거래", systemImage: "arrow.3.trianglepath")
            }
            .tag(ANBDTabViewType.trade)
            
            
            /// Chat
            NavigationStack(path: $coordinator.chatPath) {
                ChatView()
                    .navigationDestination(for: Page.self) { page in
                        coordinator.build(page)
                    }
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.right")
            }
            .tag(ANBDTabViewType.chat)
            
            
            /// Mypage
            NavigationStack(path: $coordinator.mypagePath) {
                UserPageView(writerUser: UserStore.shared.user)
                    .navigationDestination(for: Article.self) { article in
                        ArticleDetailView(article: article, comment: articleViewModel.comment)
                    }
                    .navigationDestination(for: Trade.self) { trade in
                        TradeDetailView(trade: trade)
                    }
                    .navigationDestination(for: ANBDCategory.self) { category in
                        UserActivityListView(category: category)
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
            .tag(ANBDTabViewType.mypage)
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
