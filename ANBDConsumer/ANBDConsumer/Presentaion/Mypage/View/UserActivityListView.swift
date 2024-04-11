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
                .padding()
            
            TabView(selection: $category) {
                UserArticleListView(category: .accua)
                    .tag(ANBDCategory.accua)
                
                UserTradeListView(category: .nanua)
                    .tag(ANBDCategory.nanua)
                
                UserTradeListView(category: .baccua)
                    .tag(ANBDCategory.baccua)
                
                UserArticleListView(category: .dasi)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationTitle("\(user.nickname)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Article.self, destination: { article in
            ArticleDetailView(article: article)
                .toolbarRole(.editor)
        })
        .navigationDestination(for: Trade.self, destination: { trade in
            TradeDetailView(trade: trade)
                .toolbarRole(.editor)
        })
        
        .toolbar(.hidden, for: .tabBar)
        
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
    func ListEmptyView() -> some View {
        VStack {
            ContentUnavailableView("\(user.nickname)님의\n\(category.description) 활동이 없습니다.",
                                   systemImage: "tray",
                                   description: Text(""))
        }
    }
    
    @ViewBuilder
    func UserArticleListView(category: ANBDCategory) -> some View {
        if articlesWrittenByUser.isEmpty {
            ListEmptyView()
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(articlesWrittenByUser.filter({$0.category == category})) { article in
                        NavigationLink(value: article) {
                            ArticleListCell(article: article)
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
    func UserTradeListView(category: ANBDCategory) -> some View {
        VStack {
            if tradesWrittenByUser.isEmpty {
                ListEmptyView()
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(tradesWrittenByUser.filter({$0.category == category})) { trade in
                            NavigationLink(value: trade) {
                                TradeListCell(trade: trade)
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
