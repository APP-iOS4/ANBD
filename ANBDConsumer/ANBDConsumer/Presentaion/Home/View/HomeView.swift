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
    @State private var isShowingWebView: Bool = false
    @State private var blogURL: String = "https://www.naver.com"
    
    var body: some View {
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
                NavigationLink(value: "") {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 20)
                        .foregroundStyle(.gray900)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingWebView) {
            SafariWebView(url: URL(string: blogURL) ?? URL(string: "www.naver.com")!)
                .ignoresSafeArea(edges: .bottom)
        }
    }
    
    
    // MARK: - 광고 배너
    private var adView: some View {
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
                                .scaledToFill()
                            
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
    }
    
    // MARK: - 아껴쓰기 Section
    private func accuaView(geo: GeometryProxy) -> some View {
        VStack {
            sectionHeaderView(.accua)
            
            if let article = homeViewModel.accuaArticle {
                NavigationLink(value: homeViewModel.accuaArticle) {
                    ArticleCellView(article: article)
                        .frame(width: geo.size.width * 0.9, height: 130)
                }
            }
        }
    }
    
    // MARK: - 나눠쓰기 Section
    private var nanuaView: some View {
        VStack(alignment: .leading) {
            sectionHeaderView(.nanua)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(homeViewModel.nanuaTrades) { trade in
                        NavigationLink(value: trade) {
                            NanuaCellView(trade: trade)
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
            sectionHeaderView(.baccua)
            
            ForEach(homeViewModel.baccuaTrades) { trade in
                NavigationLink(value: trade) {
                    ArticleListCell(value: .trade(trade))
                }
            }
        }
    }
    
    // MARK: - 다시쓰기 Section
    private func dasiView(geo: GeometryProxy) -> some View {
        VStack {
            sectionHeaderView(.dasi)
            
            NavigationLink(value: homeViewModel.dasiArticle) {
                if let dasiArticle = homeViewModel.dasiArticle {
                    ArticleCellView(article: dasiArticle)
                        .frame(width: geo.size.width * 0.9, height: 130)
                }
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
    struct ArticleCellView: View {
        var article: Article
        @State private var imageData: Data?
        @EnvironmentObject private var homeViewModel: HomeViewModel
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                VStack {
                    if let imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
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
        
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                VStack {
                    if let imageData {
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(height: 140)
                                .scaledToFill()
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
    }
}
