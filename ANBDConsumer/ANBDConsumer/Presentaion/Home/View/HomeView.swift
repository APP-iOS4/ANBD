//
//  HomeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @State private var isGoingToSearchView: Bool = false
    @State private var category: ANBDCategory = .accua
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack {
                    adView
                    
                    AccuaView(geo: geometry)
                    
                    Divider()
                        .padding(.vertical, 20)
                    
                    nanuaView
                    
                    Divider()
                        .padding(.vertical, 20)
                    
                    baccuaView
                    
                    Divider()
                        .padding(.vertical, 20)
                    
                    DasiView(geo: geometry)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("ANBD")
                    .font(ANBDFont.pretendardBold(40))
                    .foregroundStyle(.gray900)
                    .padding(.leading, 4)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isGoingToSearchView.toggle()
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                })
            }
        }
        .fullScreenCover(isPresented: $homeViewModel.isShowingWebView) {
            SafariWebView(url: URL(string: homeViewModel.blogURL) ?? URL(string: "www.naver.com")!)
        }
        .navigationDestination(for: ANBDCategory.self) { category in
            switch category {
            case .accua, .dasi:
                ArticleListView(category: category, isFromHomeView: true)
                
            case .nanua, .baccua:
                TradeListView(category: category, isFromHomeView: true)
            }
        }
        .navigationDestination(for: Article.self) { article in
            ArticleDetailView(article: article)
        }
        .navigationDestination(for: Trade.self) { trade in
            TradeDetailView(trade: trade)
        }
        .navigationDestination(isPresented: $isGoingToSearchView) {
            SearchView()
        }
    }
    
    
    // MARK: - 광고 배너
    private var adView: some View {
        NormalCarouselView(homeViewModel.bannerItemList) { item in
            AsyncImage(url: URL(string: item.imageStirng)) { img in
                img
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 36)
    }
    
    
    // MARK: - 아껴쓰기 Section
    @ViewBuilder
    private func AccuaView(geo: GeometryProxy) -> some View {
        VStack {
            SectionHeaderView(.accua)
            
            NavigationLink(value: homeViewModel.accuaArticle) {
                ArticleCellView(homeViewModel.accuaArticle)
                    .frame(width: geo.size.width * 0.9, height: 130)
            }
        }
    }
    
    // MARK: - 나눠쓰기 Section
    private var nanuaView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(.nanua)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(homeViewModel.nanuaTrades) { trade in
                        NavigationLink(value: trade) {
                            NanuaCellView(trade)
                                .frame(width: 140, height: 140)
                                .padding(.horizontal, 1)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - 바꿔쓰기 Section
    private var baccuaView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(.baccua)
            
            ForEach(homeViewModel.baccuaTrades) { trade in
                NavigationLink(value: trade) {
                    TradeListCell(trade: trade)
                }
            }
        }
    }
    
    // MARK: - 다시쓰기 Section
    @ViewBuilder
    private func DasiView(geo: GeometryProxy) -> some View {
        VStack {
            SectionHeaderView(.dasi)
            
            NavigationLink(value: homeViewModel.dasiArticle) {
                ArticleCellView(homeViewModel.dasiArticle)
                    .frame(width: geo.size.width * 0.9, height: 130)
            }
        }
    }
    
    // MARK: - ANBD 각 섹션 헤더 View
    @ViewBuilder
    private func SectionHeaderView(_ category: ANBDCategory) -> some View {
        VStack(alignment: .leading) {
            HStack {
                switch category {
                case .accua:
                    Text("아껴쓰기")
                        .font(ANBDFont.Heading3)
                case .nanua:
                    Text("나눠쓰기")
                        .font(ANBDFont.Heading3)
                case .baccua:
                    Text("바꿔쓰기")
                        .font(ANBDFont.Heading3)
                case .dasi:
                    Text("다시쓰기")
                        .font(ANBDFont.Heading3)
                }
                
                Spacer()
                
                NavigationLink(value: category) {
                    HStack {
                        Text("더보기")
                        
                        Image(systemName: "chevron.forward")
                    }
                    .font(ANBDFont.body2)
                }
            }
            .padding(.bottom, 3)
            
            
            switch category {
            case .accua:
                Text("환경을 위해 아껴쓰세요.")
                    .font(ANBDFont.body1)
            case .nanua:
                Text("환경을 위해 Divide.")
                    .font(ANBDFont.body1)
            case .baccua:
                Text("어? 너도? 나도!")
                    .font(ANBDFont.body1)
            case .dasi:
                Text("버리지 말고 새롭게 써보세요.")
                    .font(ANBDFont.body1)
            }
        }
        .foregroundStyle(.gray900)
    }
    
    // MARK: - 아껴쓰기 · 다시쓰기 Cell View
    @ViewBuilder
    private func ArticleCellView(_ article: Article) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(article.imagePaths.first ?? "DummyImage1")
                .resizable()
                .scaledToFill()
                .frame(height: 130)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            Text(article.title)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(10)
                .padding(.trailing, 70)
                .foregroundStyle(.white)
                .font(ANBDFont.SubTitle1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .foregroundStyle(.gray900)
    }
    
    // MARK: - 나눠쓰기 Cell View
    @ViewBuilder
    private func NanuaCellView(_ trade: Trade) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(trade.imagePaths.first ?? "DummyImage1")
                .resizable()
                .frame(width: 140, height: 140)
                .scaledToFit()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            Text(trade.title)
                .lineLimit(1)
                .padding(10)
                .padding(.trailing, 20)
                .foregroundStyle(.white)
                .font(ANBDFont.SubTitle1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(HomeViewModel())
    }
}
