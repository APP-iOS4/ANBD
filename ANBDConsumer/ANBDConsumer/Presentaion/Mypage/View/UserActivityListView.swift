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
    @State var user: User
    
    @State private var isSignedInUser: Bool = false
    
    @State private var articlesWrittenByUser: [Article] = []
    @State private var tradesWrittenByUser: [Trade] = []
    
    private var filterdArticlesWrittenByUser: [Article] {
        return articlesWrittenByUser.filter({$0.category == category})
    }
    private var filterdTradesWrittenByUser: [Trade] {
        return tradesWrittenByUser.filter({$0.category == category})
    }
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 20)
                .padding([.leading, .trailing, .bottom])
            
            TabView(selection: $category) {
                userArticleListView(category: .accua)
                    .tag(ANBDCategory.accua)
                
                userTradeListView(category: .nanua)
                    .tag(ANBDCategory.nanua)
                
                userTradeListView(category: .baccua)
                    .tag(ANBDCategory.baccua)
                
                userArticleListView(category: .dasi)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        
        .navigationTitle("\(user.nickname)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            /*
             Task {
             articlesWrittenByUser = try await articleUseCase.loadArticleList(writerID: user.id)
             tradesWrittenByUser = try await tradeUseCase.loadTradeList(writerID: user.id)
             }
             */
            articlesWrittenByUser = myPageViewModel.articlesWrittenByUser
            tradesWrittenByUser = myPageViewModel.tradesWrittenByUser
        }
    }
    
    @ViewBuilder
    private func userArticleListView(category: ANBDCategory) -> some View {
        if articlesWrittenByUser.isEmpty {
            ListEmptyView(description: emptyArticleListDescription)
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(articlesWrittenByUser.filter({$0.category == category})) { article in
                        NavigationLink(value: article) {
                            ArticleListCell(value: .article(article))
                                .padding(.vertical, 5)
                        }
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("\(filterdArticlesWrittenByUser.count)")
                            .foregroundStyle(Color.accent)
                        Text("건의 \(category.description) 활동을 했어요.")
                    }
                    .font(ANBDFont.Caption3)
                    .foregroundStyle(.gray400)
                    .frame(height: 40, alignment: .center)
                    
                    Divider()
                }
                .padding(.horizontal, 20)
                .background(.white)
            }
            .background(.gray50)
        }
    }
    
    @ViewBuilder
    private func userTradeListView(category: ANBDCategory) -> some View {
        VStack {
            if tradesWrittenByUser.isEmpty {
                ListEmptyView(description: emptyTradeListDescription)
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(tradesWrittenByUser.filter({$0.category == category})) { trade in
                            NavigationLink(value: trade) {
                                ArticleListCell(value: .trade(trade))
                                    .padding(.vertical, 5)
                            }
                            
                            Divider()
                        }
                        
                        HStack {
                            Text("\(filterdTradesWrittenByUser.count)")
                                .foregroundStyle(Color.accent)
                            Text("건의 \(category.description) 활동을 했어요.")
                        }
                        .font(ANBDFont.Caption3)
                        .foregroundStyle(.gray400)
                        .frame(height: 40, alignment: .center)
                        
                        Divider()
                    }
                    .padding(.horizontal, 20)
                    .background(.white)
                }
                .background(.gray50)
            }
        }
    }
}

extension UserActivityListView {
    // TODO: - 다른 유저 정보 필요
//    private var navigationTitle: String {
//        
//    }
    
    private var emptyArticleListDescription: String {
        switch isSignedInUser {
        case true: return "\(user.nickname)님의\n\(category.description) 활동이 없습니다."
        case false: return "수정 필요"
        }
    }
    
    private var emptyTradeListDescription: String {
        switch isSignedInUser {
        case true: return "\(user.nickname)님의\n\(category.description) 활동이 없습니다."
        case false: return "수정 필요"
        }
    }
}

#Preview {
    NavigationStack {
        UserActivityListView(category: .accua,
                             user: MyPageViewModel.mockUser)
        .environmentObject(MyPageViewModel())
        .environmentObject(ArticleViewModel())
        .environmentObject(TradeViewModel())
    }
}
