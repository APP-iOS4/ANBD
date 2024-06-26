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
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var coordinator = Coordinator.shared
    
    @State var category: ANBDCategory
    
    var isSignedInUser: Bool
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 20)
                .padding([.leading, .trailing, .bottom])
            
            TabView(selection: $category) {
                userArticleListView(articles: myPageViewModel.accuaArticlesWrittenByUser)
                    .tag(ANBDCategory.accua)
                
                userTradeListView(trades: myPageViewModel.nanuaTradesWrittenByUser)
                    .tag(ANBDCategory.nanua)
                
                userTradeListView(trades: myPageViewModel.baccuaTradesWrittenByUser)
                    .tag(ANBDCategory.baccua)
                
                userArticleListView(articles: myPageViewModel.dasiArticlesWrittenByUser)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        
        .navigationTitle("\(navigationTitle)님의 ANBD")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            Task {
                coordinator.isFromUserPage = true
                await myPageViewModel.loadAllUserActivityList(by: myPageViewModel.user.id)
            }
        }
    }
    
    @ViewBuilder
    private func userArticleListView(articles: [Article]) -> some View {
        if articles.isEmpty {
            ZStack {
                ListEmptyView(description: "\(myPageViewModel.user.nickname)님의\n\(category.description) 활동이 없습니다.")
                
                if isSignedInUser {
                    Button(action: {
                        dismiss()
                        coordinator.selectedTab = .article
                    }, label: {
                        HStack {
                            Text("활동하러 가기")
                                .font(ANBDFont.body1)
                            Image(systemName: "chevron.forward")
                                .font(ANBDFont.Caption3)
                        }
                    })
                    .offset(y: 100)
                }
            }
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(articles) { article in
                        ArticleListCell(value: .article(article))
                            .padding(.vertical, 5)
                            .onTapGesture {
                                coordinator.article = article
                                coordinator.appendPath(.articleDeatilView)
                            }
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("\(articles.count)")
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
    private func userTradeListView(trades: [Trade]) -> some View {
        VStack {
            if trades.isEmpty {
                ZStack {
                    ListEmptyView(description: "\(myPageViewModel.user.nickname)님의\n\(category.description) 활동이 없습니다.")
                    
                    if isSignedInUser {
                        Button(action: {
                            dismiss()
                            coordinator.selectedTab = .trade
                        }, label: {
                            HStack {
                                Text("활동하러 가기")
                                    .font(ANBDFont.body1)
                                Image(systemName: "chevron.forward")
                                    .font(ANBDFont.Caption3)
                            }
                        })
                        .offset(y: 100)
                    }
                }
            } else {
                ScrollView(.vertical) {
                    LazyVStack {
                        ForEach(trades) { trade in
                            
                            ArticleListCell(value: .trade(trade))
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    coordinator.trade = trade
                                    tradeViewModel.getOneTrade(trade: trade)
                                    coordinator.appendPath(.tradeDetailView)
                                }
                                .onAppear {
                                    tradeViewModel.detailImages = []
                                }
                            
                            Divider()
                        }
                        
                        HStack {
                            Text("\(trades.count)")
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

extension UserActivityListView {
    private var navigationTitle: String {
        if myPageViewModel.user.nickname.count > 12 {
            let title = myPageViewModel.user.nickname.prefix(12)
            
            return "\(title)..."
        } else {
            return myPageViewModel.user.nickname
        }
    }
}

#Preview {
    NavigationStack {
        UserActivityListView(category: .accua, isSignedInUser: true)
            .environmentObject(MyPageViewModel())
            .environmentObject(TradeViewModel())
    }
}
