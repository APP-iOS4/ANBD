//
//  UserLikedContentsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/12/24.
//

import SwiftUI
import ANBDModel

struct UserLikedContentsView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    @State var category: ANBDCategory
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category)
                .frame(height: 20)
                .padding([.leading, .trailing, .bottom])
            
            switch category {
            case .accua, .dasi:
                TabView(selection: $category) {
                    userLikedArticleListView(category: .accua)
                        .tag(ANBDCategory.accua)
                    
                    userLikedArticleListView(category: .dasi)
                        .tag(ANBDCategory.dasi)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .bottom)
                
            case .nanua, .baccua:
                TabView(selection: $category) {
                    userHeartTradeListView(category: .nanua)
                        .tag(ANBDCategory.nanua)
                    
                    userHeartTradeListView(category: .baccua)
                        .tag(ANBDCategory.baccua)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationTitle("\(navigationTitile)")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        
        .onAppear {
            Task {
                await myPageViewModel.loadUserLikedArticles(user: UserStore.shared.user)
                await myPageViewModel.loadUserHeartedTrades(user: UserStore.shared.user)
            }
        }
    }
    
    private func listEmptyView() -> some View {
        switch category {
        case .accua, .dasi:
            ListEmptyView(description: "\(UserStore.shared.user.nickname)님이 좋아요한\n\(category.description) 게시글이 없습니다.")
        case .nanua, .baccua:
            ListEmptyView(description: "\(UserStore.shared.user.nickname)님이 찜한\n\(category.description) 거래가 없습니다.")
        }
    }
    
    @ViewBuilder
    private func userLikedArticleListView(category: ANBDCategory) -> some View {
        if myPageViewModel.userLikedArticles.isEmpty {
            listEmptyView()
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(myPageViewModel.userLikedArticles.filter({$0.category == category})) { article in
                        
                        ArticleListCell(value: .article(article))
                            .padding(.vertical, 5)
                            .onTapGesture {
                                coordinator.article = article
                                coordinator.appendPath(.articleDeatilView)
                            }
                        
                        Divider()
                    }
                }
                .padding(.horizontal, 20)
                .background(.white)
            }
            .background(.gray50)
        }
    }
    
    @ViewBuilder
    private func userHeartTradeListView(category: ANBDCategory) -> some View {
        if myPageViewModel.userHeartedTrades.isEmpty {
            listEmptyView()
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(myPageViewModel.userHeartedTrades.filter({$0.category == category})) { trade in

                        ArticleListCell(value: .trade(trade))
                            .padding(.vertical, 5)
                            .onTapGesture {
                                coordinator.trade = trade
                                coordinator.appendPath(.tradeDetailView)
                            }
                        
                        Divider()
                    }
                }
                .padding(.horizontal, 20)
                .background(.white)
            }
            .background(.gray50)
        }
    }
}

extension UserLikedContentsView {
    private var navigationTitile: String {
        switch category {
        case .accua, .dasi:
            return "좋아요한 게시글"
        case .nanua, .baccua:
            return "찜한 나눔 · 거래"
        }
    }
}

#Preview {
    NavigationStack {
        UserLikedContentsView(category: .accua)
            .environmentObject(MyPageViewModel())
            .environmentObject(ArticleViewModel())
    }
}
