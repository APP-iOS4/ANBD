//
//  ArticleView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/6/24.
//

import SwiftUI
import ANBDModel
import Combine

struct ArticleView: View {
    @StateObject private var coordinator = Coordinator.shared
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @State private var isShowingArticleCreateView: Bool = false
    @State private var isShowingTradeCreateView: Bool = false
    
    @Binding var category: ANBDCategory
    
    @State private var isArticle: Bool = true
    
    var body: some View {
        listView
            .onChange(of: category) {
                if isArticle {
                    Task {
                        await articleViewModel.refreshSortedArticleList(category: category)
                    }
                } else {
                    Task {
                        await tradeViewModel.reloadFilteredTrades(category: category)
                    }
                }
            }
    }
    
    // MARK: - article 서브뷰
    private var listView: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 35)
                
                TabView(selection: $category) {
                    ArticleListView(category: isArticle ? .accua : .nanua,
                                    isArticle: isArticle)
                    .tag(isArticle ? ANBDCategory.accua : ANBDCategory.nanua)
                    
                    ArticleListView(category: isArticle ? .dasi : .baccua,
                                    isArticle: isArticle)
                    .tag(isArticle ? ANBDCategory.dasi : ANBDCategory.baccua)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button {
                if !networkMonitor.isConnected {
                    ToastManager.shared.toast = Toast(style: .error, message: "인터넷 연결을 확인해주세요.")
                } else {
                    if isArticle {
                        self.isShowingArticleCreateView.toggle()
                    } else {
                        self.isShowingTradeCreateView.toggle()
                    }
                }
            } label: {
                WriteButtonView()
            }
        }
        .onAppear {
            coordinator.isFromUserPage = false
            
            if category == .accua || category == .dasi {
                isArticle = true
                Task {
                    await articleViewModel.refreshSortedArticleList(category: category)
                }
            } else {
                isArticle = false
                Task {
                    await tradeViewModel.reloadFilteredTrades(category: category)
                }
            }
        }
        .navigationTitle(isArticle ? "정보 공유" : "나눔 · 거래")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    coordinator.category = category
                    coordinator.appendPath(.searchView)
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                })
            }
        }
        .fullScreenCover(isPresented: $isShowingArticleCreateView, onDismiss: {
            Task {
                await articleViewModel.refreshSortedArticleList(category: category)
            }
        }, content: {
            ArticleCreateView(isShowingCreateView: $isShowingArticleCreateView, category: category, isNewArticle: true)
        })
        .fullScreenCover(isPresented: $isShowingTradeCreateView, onDismiss: {
            Task {
                await tradeViewModel.reloadFilteredTrades(category: category)
            }
        }, content: {
            TradeCreateView(isShowingCreate: $isShowingTradeCreateView, category: category, isNewProduct: true)
        })
    }
}
