//
//  HomeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeViewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                adView
                
                accuaView
                
                Divider()
                    .padding(.vertical, 20)
                
                nanuaView
                
                Divider()
                    .padding(.vertical, 20)
                
                baccuaView
                
                Divider()
                    .padding(.vertical, 20)
                
                dasiView
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("ANBD")
                    .font(ANBDFont.pretendardBold(40))
                    .foregroundStyle(.gray900)
                    .padding(.leading, 4)
            }
            
            /// SearchView로 이동
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    
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
    private var accuaView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(.accua)
            
            CommunityCellView(.accua)
        }
    }
    
    // MARK: - 나눠쓰기 Section
    private var nanuaView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(.nanua)
            
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(0..<4) { _ in
                        NanuaCellView()
                            .frame(width: 140, height: 140)
                            .padding(.horizontal, 1)
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
            
            // TODO: TradeCell 풀 받을 시 체인지
            baccuaCell
            
            baccuaCell
        }
    }
    
    // MARK: - 다시쓰기 Section
    private var dasiView: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(.dasi)
            
            CommunityCellView(.dasi)
        }
    }
    
    // TODO: TradeCell 풀 받을 시 체인지
    private var baccuaCell: some View {
        HStack(alignment: .top) {
            Image("DummyImage1")
                .resizable()
                .frame(width: 130, height: 130)
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                Text("바꿔쓰기 제목")
                    .font(ANBDFont.pretendardRegular(20))
                Text("8분전")
                    .foregroundStyle(.gray400)
                Text("물물교환")
                    .font(ANBDFont.pretendardBold(15))
            }
        }
        .foregroundStyle(.gray900)
    }
    
    // MARK: - ANBD 각 섹션 헤더 View
    @ViewBuilder
    private func SectionHeaderView(_ category: Category) -> some View {
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
                
                Button(action: {
                    
                }, label: {
                    HStack {
                        Text("더보기")
                        
                        Image(systemName: "chevron.forward")
                    }
                })
                .font(ANBDFont.body2)
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
    // TODO: 추후 파라미터 category -> community 값으루 변경
    @ViewBuilder
    private func CommunityCellView(_ category: Category) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image("DummyImage1")
                .resizable()
                .scaledToFill()
                .frame(height: 130)
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            Text("ㅋㅋㅋㅋ 마루가 마루임 마루는 마루임 관리자가 해라 ~~ 딥해서 ~ 통일한대루 니네맘대루 해라")
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
    // TODO: 추후 파라미터 trade 값 받아야 함
    @ViewBuilder
    private func NanuaCellView() -> some View {
        ZStack(alignment: .bottomLeading) {
            Image("DummyImage1")
                .resizable()
                .frame(width: 140, height: 140)
                .scaledToFit()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.4)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            Text("나눠쓰기나눠쓰기나눠쓰기나눠쓰기나눠쓰기")
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
