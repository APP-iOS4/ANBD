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
    
    // 연습용 임시 제가 이거 임시로 만들었었는데 주말에 연습해본다고!!!
    // 
    private let articleUseCase: ArticleUsecase = DefaultArticleUsecase()
    private let tradeUseCase: TradeUsecase = DefaultTradeUsecase()
    private let userUseCase: UserUsecase = DefaultUserUsecase()
    
    @State var category: ANBDCategory
    @State var user: User
    
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
        
        .navigationTitle("\(user.nickname)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            /*
             Task {
             articlesWrittenByUser = try await articleUseCase.loadArticleList(writerID: user.id)
             tradesWrittenByUser = try await tradeUseCase.loadTradeList(writerID: user.id)
             }
             */
            articlesWrittenByUser = myPageViewModel.mockArticleData
            tradesWrittenByUser = myPageViewModel.mockTradeData
        }
    }
    
    @ViewBuilder
    private func userArticleListView(category: ANBDCategory) -> some View {
        if articlesWrittenByUser.isEmpty {
            ListEmptyView(description: "\(user.nickname)님의\n\(category.description) 활동이 없습니다.")
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
                ListEmptyView(description: "\(user.nickname)님의\n\(category.description) 활동이 없습니다.")
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

#Preview {
    NavigationStack {
        UserActivityListView(category: .accua,
                             user: MyPageViewModel.mockUser)
        .environmentObject(MyPageViewModel())
        .environmentObject(ArticleViewModel())
        .environmentObject(TradeViewModel())
    }
}
