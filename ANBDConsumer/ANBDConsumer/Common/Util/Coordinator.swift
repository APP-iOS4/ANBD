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
}

final class Coordinator: ObservableObject {
    
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
    @Published var user: User = .init(id: "", nickname: "", email: "", favoriteLocation: .busan, isOlderThanFourteen: true, isAgreeService: true, isAgreeCollectInfo: true, isAgreeMarketing: true)
    
    
    /// append
    @ViewBuilder
    func build(_ page: Page) -> some View {
        switch page {
        case .articleListView:
            ArticleListView(category: category, isArticle: (category == .accua || category == .dasi), isFromHomeView: true)
           
        // TODO: 수정 필요
        case .articleDeatilView:
            if let article = article {
                EmptyView()
            }
            
        case .tradeDetailView:
            if let trade = trade {
                TradeDetailView(trade: trade)
            }
            
        case .searchView:
            SearchView()
            
        case .searchResultView:
            SearchResultView(category: category, searchText: "")
            
        case .chatDetailView:
            ChatDetailView(trade: trade)
            
        case .reportView:
            ReportView(reportViewType: reportType, reportedObjectID: reportedObjectID, reportedChannelID: reportedChannelID)
            
        case .userPageView:
            UserPageView(writerUser: user)
        }
    }
    
    /// dismiss
    func pop(_ viewType: ANBDTabViewType) {
        switch viewType {
        case .home:
            homePath.removeLast()
        case .article:
            articlePath.removeLast()
        case .trade:
            tradePath.removeLast()
        case .chat:
            chatPath.removeLast()
        case .mypage:
            mypagePath.removeLast()
        }
    }
}
