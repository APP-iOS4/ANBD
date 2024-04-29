//
//  Coordinator.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/22/24.
//

import SwiftUI
import ANBDModel

enum ANBDTabViewType {
    case home, article, trade, chat, mypage
}

enum Page {
    case articleListView
    case articleDeatilView
    case tradeDetailView
    
    case searchView
    case searchResultView
    
    case chatDetailView
    case reportView
    
    case userPageView
    case userInfoEditingView
    case userActivityView
    case userLikedContentView
    case settingsView
}

final class Coordinator: ObservableObject {
    @Published var selectedTab: ANBDTabViewType = .home
    
    /// path
    @Published var homePath: NavigationPath = NavigationPath()
    @Published var articlePath: NavigationPath = NavigationPath()
    @Published var tradePath: NavigationPath = NavigationPath()
    @Published var chatPath: NavigationPath = NavigationPath()
    @Published var mypagePath: NavigationPath = NavigationPath()
    
    @Published var category: ANBDCategory = .accua
    @Published var article: Article?
    @Published var trade: Trade?
    @Published var reportType: ReportType = .trade
    @Published var reportedObjectID: String = ""
    @Published var reportedChannelID: String?
    @Published var user: User?
    @Published var searchText: String = ""
    @Published var channel: Channel?
    @Published var isFromUserPage: Bool = false
    @Published var toastViewType: ToastViewType = .report
    @Published var isShowingToastView: Bool = false
    
    
    @ViewBuilder
    func build(_ page: Page) -> some View {
        switch page {
        case .articleListView:
            ArticleListView(category: category, isArticle: (category == .accua || category == .dasi), isFromHomeView: true)
            
        case .articleDeatilView:
            if let article = article {
                ArticleDetailView(article: article)
            }
            
        case .tradeDetailView:
            if let trade = trade {
                TradeDetailView(trade: trade)
            }
            
        case .searchView:
            SearchView()
            
        case .searchResultView:
            SearchResultView(category: category, searchText: searchText)
            
        case .chatDetailView:
            ChatDetailView()
            
        case .reportView:
            ReportView(reportViewType: reportType, reportedObjectID: reportedObjectID, reportedChannelID: reportedChannelID)
            
        case .userPageView:
            if let user = user {
                UserPageView(writerUser: user)
            }
        
        case .userInfoEditingView:
            UserInfoEditingView()
            
        case .userActivityView:
            UserActivityListView(category: category)
            
        case .userLikedContentView:
            UserLikedContentsView(category: category)
            
        case .settingsView:
            SettingsView()
        }
    }
    
    /// append
    func appendPath(_ page: Page) {
        switch selectedTab {
        case .home:
            homePath.append(page)
        case .article:
            articlePath.append(page)
        case .trade:
            tradePath.append(page)
        case .chat:
            chatPath.append(page)
        case .mypage:
            mypagePath.append(page)
        }
    }
    
    
    /// dismiss
    func pop(_ depth: Int = 1) {
        switch selectedTab {
        case .home:
            homePath.removeLast(depth)
        case .article:
            articlePath.removeLast(depth)
        case .trade:
            tradePath.removeLast(depth)
        case .chat:
            chatPath.removeLast(depth)
        case .mypage:
            mypagePath.removeLast(depth)
        }
    }
}
