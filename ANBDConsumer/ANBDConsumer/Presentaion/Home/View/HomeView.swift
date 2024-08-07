//
//  HomeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel
import SkeletonUI

struct HomeView: View {
    @StateObject private var coordinator = Coordinator.shared
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @State private var isShowingWebView: Bool = false
    @State private var isLoading: Bool = true
    @State private var blogURL: String = "https://www.naver.com"
    
    var body: some View {
        mainView
            .onChange(of: networkMonitor.isConnected) {
                if networkMonitor.isConnected {
                    Task {
                        //광고
                        await homeViewModel.loadBanners()
                        blogURL = homeViewModel.bannerItemList.first?.urlString ?? "https://www.naver.com"
                        //아껴
                        await homeViewModel.loadArticle(category: .accua)
                        //나눠
                        await homeViewModel.loadArticle(category: .nanua)
                        //다시
                        await homeViewModel.loadArticle(category: .dasi)
                        //isLoading = false
                    }
                }
            }
    }
    
    private var mainView: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack {
                    adView
                        .padding(.bottom, 20)
                    
                    accuaView(geo: geometry)
                    
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    nanuaView
                    
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    baccuaView
                    
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    
                    dasiView(geo: geometry)
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
                    coordinator.homePath.append(Page.searchView)
                }, label: {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                })
                
            }
        }
        .fullScreenCover(isPresented: $isShowingWebView) {
            SafariWebView(url: URL(string: blogURL) ?? URL(string: "www.naver.com")!)
                .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            coordinator.isFromUserPage = false
        }
    }
    
    // MARK: - 광고 배너
    private var adView: some View {
        ZStack {
            TabView() {
                ForEach(homeViewModel.bannerItemList) { banner in
                    Button(action: {
                        blogURL = banner.urlString
                        isShowingWebView.toggle()
                    }, label: {
                        ZStack {
                            AsyncImage(url: URL(string: banner.thumbnailImageURLString)) { img in
                                img
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onAppear {
                                        isLoading = false
                                    }
                                
                            } placeholder: {
                                ProgressView()
                            }
                            
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                        }
                    })
                }
            }
            .onAppear {
                Task {
                    await homeViewModel.loadBanners()
                    blogURL = homeViewModel.bannerItemList.first?.urlString ?? "https://www.naver.com"
                }
            }
            .frame(height: 130)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            Color.clear
                .skeleton(with: isLoading , shape: .rectangle)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    // MARK: - 아껴쓰기 Section
    private func accuaView(geo: GeometryProxy) -> some View {
        VStack {
            sectionHeaderView(.accua)
            ZStack {
                if let article = homeViewModel.accuaArticle {
                    Button(action: {
                        Task {
                            coordinator.article = article
                            await articleViewModel.loadArticle(article: article)
                            coordinator.homePath.append(Page.articleDeatilView)
                        }
                    }, label: {
                        ZStack {
                            ArticleCellView(article: article)
                                .frame(width: geo.size.width * 0.9, height: 130)
                        }
                        
                    })
                }
                Color.clear
                    .skeleton(with: isLoading , shape: .rectangle)
                    .frame(width: geo.size.width * 0.9, height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .onAppear {
            Task {
                await homeViewModel.loadArticle(category: .accua)
            }
        }
    }
    
    // MARK: - 나눠쓰기 Section
    private var nanuaView: some View {
        VStack(alignment: .leading) {
            sectionHeaderView(.nanua)
            
            ScrollView(.horizontal , showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    LazyHStack {
                        ForEach(homeViewModel.nanuaTrades) { trade in
                            Button(action: {
                                coordinator.trade = trade
                                tradeViewModel.getOneTrade(trade: trade)
                                coordinator.homePath.append(Page.tradeDetailView)
                            }, label: {
                                NanuaCellView(trade: trade)
                                    .frame(width: 140, height: 140)
                                    .padding(.horizontal, 1)
                            })
                        }
                    }
                    
                    LazyHStack {
                        ForEach(1..<4) { _ in
                            Color.clear
                                .skeleton(with: isLoading , shape: .rectangle)
                                .frame(width: 140, height: 140)
                                .padding(.horizontal, 1)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await homeViewModel.loadTrades(category: .nanua)
            }
        }
    }
    
    // MARK: - 바꿔쓰기 Section
    private var baccuaView: some View {
        VStack(alignment: .leading) {
            sectionHeaderView(.baccua)
            VStack {
                ForEach(homeViewModel.baccuaTrades) { trade in
                    Button(action: {
                        coordinator.trade = trade
                        tradeViewModel.getOneTrade(trade: trade)
                        coordinator.homePath.append(Page.tradeDetailView)
                    }, label: {
                        ArticleListCell(value: .trade(trade))
                    })
                }
            }
        }
        .onAppear {
            Task {
                await homeViewModel.loadTrades(category: .baccua)
            }
        }
    }
    
    // MARK: - 다시쓰기 Section
    private func dasiView(geo: GeometryProxy) -> some View {
        VStack {
            sectionHeaderView(.dasi)
            
            if let dasiArticle = homeViewModel.dasiArticle {
                Button(action: {
                    Task {
                        coordinator.article = dasiArticle
                        await articleViewModel.loadArticle(article: dasiArticle)
                        coordinator.homePath.append(Page.articleDeatilView)
                    }
                }, label: {
                    ArticleCellView(article: dasiArticle)
                        .frame(width: geo.size.width * 0.9, height: 130)
                })
            }
        }
        .onAppear {
            Task {
                await homeViewModel.loadArticle(category: .dasi)
            }
        }
    }
    
    // MARK: - ANBD 각 섹션 헤더 View
    func sectionHeaderView(_ category: ANBDCategory) -> some View {
        VStack(alignment: .leading) {
            HStack {
                switch category {
                case .accua:
                    Text("아껴쓰기")
                        .font(ANBDFont.pretendardBold(24))
                case .nanua:
                    Text("나눠쓰기")
                        .font(ANBDFont.pretendardBold(24))
                case .baccua:
                    Text("바꿔쓰기")
                        .font(ANBDFont.pretendardBold(24))
                case .dasi:
                    Text("다시쓰기")
                        .font(ANBDFont.pretendardBold(24))
                }
                
                Spacer()
                
                HStack {
                    Text("더보기")
                    
                    Image(systemName: "chevron.forward")
                }
                .font(ANBDFont.body2)
                .onTapGesture {
                    Task {
                        coordinator.category = category
                        coordinator.homePath.append(Page.articleListView)
                        switch coordinator.category {
                        case .accua, .dasi:
                            await articleViewModel.refreshSortedArticleList(category: category)
                        case .nanua, .baccua:
                            await tradeViewModel.reloadFilteredTrades(category: category)
                        }
                    }
                }
            }
            .padding(.bottom, 3)
            
            
            switch category {
            case .accua:
                Text("환경을 위해 아껴쓰세요.")
                    .font(ANBDFont.body1)
            case .nanua:
                Text("환경을 위해 마음을 나눠주세요.")
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
    struct ArticleCellView: View {
        var article: Article
        @State private var imageData: Data?
        @EnvironmentObject private var homeViewModel: HomeViewModel
        @EnvironmentObject private var networkMonitor: NetworkMonitor
        
        var body: some View {
            cellView
                .onChange(of: networkMonitor.isConnected) {
                    if networkMonitor.isConnected {
                        Task {
                            imageData = try await homeViewModel.loadThumnailImage(path: .article, containerID: article.id, imagePath: article.thumbnailImagePath)
                        }
                    }
                }
        }
        
        fileprivate var cellView: some View {
            ZStack(alignment: .bottomLeading) {
                VStack {
                    if let imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 130)
                        }
                    } else {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
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
            .onAppear {
                Task {
                    imageData = try await homeViewModel.loadThumnailImage(path: .article, containerID: article.id, imagePath: article.thumbnailImagePath)
                }
            }
        }
    }
    
    // MARK: - 나눠쓰기 Cell View
    struct NanuaCellView: View {
        var trade: Trade
        @State private var imageData: Data?
        @EnvironmentObject private var homeViewModel: HomeViewModel
        @EnvironmentObject private var networkMonitor: NetworkMonitor
        
        var body: some View {
            cellView
                .onChange(of: networkMonitor.isConnected) {
                    if networkMonitor.isConnected {
                        Task {
                            imageData = try await homeViewModel.loadThumnailImage(path: .trade, containerID: trade.id, imagePath: trade.thumbnailImagePath)
                        }
                    }
                }
        }
        
        fileprivate var cellView: some View {
            ZStack(alignment: .bottomLeading) {
                VStack {
                    if let imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 140)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 140, height: 140)
                
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
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onAppear {
                Task {
                    imageData = try await homeViewModel.loadThumnailImage(path: .trade, containerID: trade.id, imagePath: trade.thumbnailImagePath)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(HomeViewModel())
            .environmentObject(TradeViewModel())
    }
}
