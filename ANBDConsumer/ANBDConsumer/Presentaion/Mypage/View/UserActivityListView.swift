//
//  UserActivityListView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/11/24.
//

import SwiftUI
import ANBDModel

struct UserActivityListView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @State var category: ANBDCategory
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
        }
        .navigationTitle("\(myPageViewModel.user.nickname)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Article.self, destination: { article in
            ArticleDetailView(article: article)
        })
        .navigationDestination(for: Trade.self, destination: { trade in
            TradeDetailView(trade: trade)
        })
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        UserActivityListView(category: .accua)
            .environmentObject(MyPageViewModel())
    }
}
