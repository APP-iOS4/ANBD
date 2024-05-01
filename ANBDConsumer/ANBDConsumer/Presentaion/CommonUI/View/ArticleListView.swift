//
//  ArticleListView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ArticleListView: View {
    @StateObject private var coordinator = Coordinator.shared
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    
    @State var category: ANBDCategory = .accua
    var isArticle: Bool = true
    var isFromHomeView: Bool = false
    var isSearchView: Bool = false
    var searchText: String? = nil
    
    @State private var isShowingLocation: Bool = false
    @State private var isShowingItemCategory: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if isArticle && articleViewModel.filteredArticles.isEmpty {
                
                ListEmptyView(description: "해당하는 정보 공유 게시글이 없습니다.")
                
            } else if !isArticle && tradeViewModel.filteredTrades.isEmpty {
                if !isSearchView {
                    loacationAndCategoryButtons
                }
                ListEmptyView(description: "해당하는 나눔 · 거래 게시글이 없습니다.")
                
            } else {
                
                //MARK: - trade 카테고리 선택 / article sort 선택
                if !isSearchView {
                    if isArticle {
                        Menu {
                            Button {
                                articleViewModel.sortOption = .latest
                                Task {
                                    await articleViewModel.refreshSortedArticleList(category: category)
                                }
                            } label: {
                                Label("최신순", systemImage: articleViewModel.sortOption == .latest ? "checkmark" : "")
                            }
                            
                            Button {
                                articleViewModel.sortOption = .mostLike
                                Task {
                                    await articleViewModel.refreshSortedArticleList(category: category)
                                }
                            } label: {
                                Label("좋아요순", systemImage: articleViewModel.sortOption == .mostLike ? "checkmark" : "")
                            }
                            
                            Button {
                                articleViewModel.sortOption = .mostComment
                                Task {
                                    await articleViewModel.refreshSortedArticleList(category: category)
                                }
                            } label: {
                                Label("댓글순", systemImage: articleViewModel.sortOption == .mostComment ? "checkmark" : "")
                            }
                        } label: {
                            CapsuleButtonView(text: articleViewModel.getSortOptionLabel(), isForFiltering: true)
                        }
                        .padding(EdgeInsets(top: 7, leading: 17, bottom: 10, trailing: 0))
                        
                    } else {
                        loacationAndCategoryButtons
                    }
                }
                
                //MARK: - list
                
                ScrollView {
                    LazyVStack {
                        if isArticle {
                            ForEach(articleViewModel.filteredArticles) { item in
                                Button(action: {
                                    coordinator.article = item
                                    articleViewModel.getOneArticle(article: item)
                                    coordinator.appendPath(.articleDeatilView)
                                }, label: {
                                    if item == articleViewModel.filteredArticles.last {
                                        ArticleListCell(value: .article(item))
                                            .padding(.vertical, 5)
                                            .onAppear {
                                                articleViewModel.detailImages = []
                                                Task {
                                                    if !isSearchView {
                                                        await articleViewModel.loadMoreArticles(category: category)
                                                    }
                                                }
                                            }
                                    } else {
                                        ArticleListCell(value: .article(item))
                                            .padding(.vertical, 5)
                                            .onAppear {
                                                articleViewModel.detailImages = []
                                            }
                                    }
                                })
                                Divider()
                            }
                            .padding(.horizontal)
                        } else {
                            ForEach(tradeViewModel.filteredTrades) { item in
                                Button(action: {
                                    coordinator.trade = item
                                    tradeViewModel.getOneTrade(trade: item)
                                    coordinator.appendPath(.tradeDetailView)
                                }, label: {
                                    if item == tradeViewModel.filteredTrades.last {
                                        ArticleListCell(value: .trade(item))
                                            .padding(.vertical, 5)
                                            .onAppear {
                                                tradeViewModel.detailImages = []
                                                Task {
                                                    if !isSearchView {
                                                        await tradeViewModel.loadMoreFilteredTrades(category: category)
                                                    }
                                                }
                                            }
                                    } else {
                                        ArticleListCell(value: .trade(item))
                                            .padding(.vertical, 5)
                                            .onAppear {
                                                tradeViewModel.detailImages = []
                                            }
                                    }
                                })
                                Divider()
                                
                            }
                            .padding(.horizontal)
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .padding(.bottom, 80)
                }
                .refreshable {
                    if !isSearchView {
                        if isArticle {
                            await articleViewModel.refreshSortedArticleList(category: category)
                        } else {
                            await tradeViewModel.reloadFilteredTrades(category: category)
                        }
                    } else {
                        guard let searchText else { return }
                        if isArticle {
                            await articleViewModel.searchArticle(keyword: searchText, category: category)
                        } else {
                            await tradeViewModel.searchTrade(keyword: searchText, category: category)
                        }
                    }
                }
                .background(.gray50)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isFromHomeView ? .hidden : .visible, for: .tabBar)
        .toolbarRole(.editor)
        .sheet(isPresented: $isShowingLocation) {
            LocationBottomSheet(isShowingLocation: $isShowingLocation, category: category)
                .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isShowingItemCategory) {
            CategoryBottomSheet(isShowingCategory: $isShowingItemCategory, category: category)
                .presentationDetents([.fraction(0.6)])
        }
    }
}

fileprivate extension ArticleListView {
    
    //MARK: - 지역 / 카테고리 필터 뷰
    
    var loacationAndCategoryButtons: some View {
        HStack {
            if !isSearchView {
                /// 지역 필터링
                Button(action: {
                    isShowingLocation.toggle()
                }, label: {
                    if tradeViewModel.selectedLocations.isEmpty {
                        CapsuleButtonView(text: "지역", isForFiltering: true)
                    } else {
                        CapsuleButtonView(text: tradeViewModel.selectedLocations.count > 1 ? "지역 \(tradeViewModel.selectedLocations.count)" : "\(tradeViewModel.selectedLocations.first?.description ?? "Unknown")", isForFiltering: true, buttonColor: .accent, fontColor: .white)
                    }
                })
                
                /// 카테고리 필터링
                Button(action: {
                    isShowingItemCategory.toggle()
                }, label: {
                    if tradeViewModel.selectedItemCategories.isEmpty {
                        CapsuleButtonView(text: "카테고리", isForFiltering: true)
                    } else {
                        CapsuleButtonView(text: tradeViewModel.selectedItemCategories.count > 1 ? "카테고리 \(tradeViewModel.selectedItemCategories.count)" : "\(tradeViewModel.selectedItemCategories.first?.rawValue ?? "Unknown")", isForFiltering: true, buttonColor: .accent, fontColor: .white)
                    }
                })
            }
        }
        .padding(EdgeInsets(top: 7, leading: 17, bottom: 10, trailing: 0))
    }
    
    //MARK: - navigationTitle
    
    var navigationTitle: String {
        if let searchText = searchText {
            return searchText
        } else if isFromHomeView {
            return category.description
        } else if isArticle {
            return "정보 공유"
        } else {
            return "나눔 · 거래"
        }
    }
}
