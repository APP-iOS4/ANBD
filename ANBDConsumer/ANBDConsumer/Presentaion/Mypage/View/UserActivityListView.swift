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
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    @State var category: ANBDCategory
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 20)
                .padding([.leading, .trailing, .bottom])
            
            TabView(selection: $category) {
                userArticleListView(list: myPageViewModel.accuaArticlesWrittenByUser)
                    .tag(ANBDCategory.accua)
                
                userTradeListView(list: myPageViewModel.nanuaTradesWrittenByUser)
                    .tag(ANBDCategory.nanua)
                
                userTradeListView(list: myPageViewModel.baccuaTradesWrittenByUser)
                    .tag(ANBDCategory.baccua)
                
                userArticleListView(list: myPageViewModel.dasiArticlesWrittenByUser)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        
        .navigationTitle("\(myPageViewModel.user.nickname)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            Task {
                await myPageViewModel.loadAllUserActivityList(by: myPageViewModel.user.id)
            }
        }
    }
    
    @ViewBuilder
    private func userArticleListView(list: [Article]) -> some View {
        if list.isEmpty {
            ListEmptyView(description: "\(myPageViewModel.user.nickname)님의\n\(category.description) 활동이 없습니다.")
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(list) { article in
                        ArticleListCell(value: .article(article))
                            .padding(.vertical, 5)
                            .onTapGesture {
                                coordinator.article = article
                                coordinator.appendPath(.articleDeatilView)
                            }
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("\(list.count)")
                            .foregroundStyle(Color.accent)
                        Text("건의 \(category.description) 활동을 했어요.")
                    }
                    .font(ANBDFont.Caption3)
                    .foregroundStyle(.gray400)
                    .frame(height: 40, alignment: .center)
                    
                    Divider()
                }
                .padding(.horizontal, 20)
                .background(Color(UIColor.systemBackground))
            }
            .background(.gray50)
        }
    }
    
    @ViewBuilder
    private func userTradeListView(list: [Trade]) -> some View {
        VStack {
            if list.isEmpty {
                ListEmptyView(description: "\(myPageViewModel.user.nickname)님의\n\(category.description) 활동이 없습니다.")
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(list) { trade in
                            
                            ArticleListCell(value: .trade(trade))
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    coordinator.trade = trade
                                    tradeViewModel.getOneTrade(trade: trade)
                                    coordinator.appendPath(.tradeDetailView)
                                }
                            
                            Divider()
                        }
                        
                        HStack {
                            Text("\(list.count)")
                                .foregroundStyle(Color.accent)
                            Text("건의 \(category.description) 활동을 했어요.")
                        }
                        .font(ANBDFont.Caption3)
                        .foregroundStyle(.gray400)
                        .frame(height: 40, alignment: .center)
                        
                        Divider()
                    }
                    .padding(.horizontal, 20)
                    .background(Color(UIColor.systemBackground))
                }
                .background(.gray50)
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserActivityListView(category: .accua)
            .environmentObject(MyPageViewModel())
            .environmentObject(ArticleViewModel())
            .environmentObject(TradeViewModel())
    }
}
