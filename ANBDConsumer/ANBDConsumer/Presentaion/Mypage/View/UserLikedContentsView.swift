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
    
    @State var category: ANBDCategory
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category)
                .frame(height: 20)
                .padding([.leading, .trailing, .bottom])
            
            switch category {
            case .accua, .dasi:
                TabView(selection: $category) {
                    UserLikedArticleListView(category: .accua)
                        .tag(ANBDCategory.accua)
                    
                    UserLikedArticleListView(category: .dasi)
                        .tag(ANBDCategory.dasi)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .bottom)
                
            case .nanua, .baccua:
                TabView(selection: $category) {
                    UserHeartTradeListView(category: .nanua)
                        .tag(ANBDCategory.nanua)
                    
                    UserHeartTradeListView(category: .baccua)
                        .tag(ANBDCategory.baccua)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationTitle("\(navigationTitile)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func ListEmptyView() -> some View {
        VStack {
            switch category {
            case .accua, .dasi:
                Spacer()
                
                Image(systemName: "tray")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .padding(.bottom, 10)
                
                HStack {
                    Spacer()
                    
                    Text("\(myPageViewModel.user.nickname)님이 좋아요한\n\(category.description) 게시글이 없습니다.")
                        .multilineTextAlignment(.center)
                        .font(ANBDFont.body1)
                    
                    Spacer()
                }
                Spacer()
                
            case .nanua, .baccua:
                Spacer()
                
                Image(systemName: "tray")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .padding(.bottom, 10)
                
                HStack {
                    Spacer()
                    
                    Text("\(myPageViewModel.user.nickname)님이 찜한\n\(category.description) 거래가 없습니다.")
                        .multilineTextAlignment(.center)
                        .font(ANBDFont.body1)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .foregroundStyle(Color.gray400)
    }
    
    @ViewBuilder
    func UserLikedArticleListView(category: ANBDCategory) -> some View {
        if myPageViewModel.mockArticleData.isEmpty {
            ListEmptyView()
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(myPageViewModel.mockArticleData.filter({$0.category == category})) { article in
                        NavigationLink(value: article) {
                            ArticleListCell(value: .article(article))
                                .padding(.vertical, 5)
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
    func UserHeartTradeListView(category: ANBDCategory) -> some View {
        if myPageViewModel.mockTradeData.isEmpty {
            ListEmptyView()
        } else {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(myPageViewModel.mockTradeData.filter({$0.category == category})) { trade in
                        NavigationLink(value: trade) {
                            TradeListCell(trade: trade)
                                .padding(.vertical, 5)
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
