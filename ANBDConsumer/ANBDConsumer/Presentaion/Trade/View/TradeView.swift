//
//  TradeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

//더미데이터
class DummyTrade {
    var trades: [Trade] = []
    
    init() {
        trades = [
            Trade(writerID: "id", writerNickname: "주리", category: .baccua, itemCategory: .beautyCosmetics, location: .busan, title: "제목", content: "너무 좋은 물건.. 바꿔요!", myProduct: "쿠션", imagePaths: ["dummyImage1"]),
            Trade(writerID: "id", writerNickname: "주리", category: .nanua, itemCategory: .beautyCosmetics, location: .busan, title: "제목", content: "너무 좋은 물건.. 바꿔요!", myProduct: "쿠션", imagePaths: ["dummyImage1"]),
            Trade(writerID: "id", writerNickname: "주리", category: .baccua, itemCategory: .beautyCosmetics, location: .busan, title: "제목", content: "너무 좋은 물건.. 바꿔요!", myProduct: "쿠션", imagePaths: ["dummyImage1"]),
        ]
    }
}

struct TradeView: View {

    @State var itemCategory: [ItemCategory] = []
    @State private var isShowingCategory: Bool = false
    @State var location: [Location] = []
    @State private var isShowingLocation: Bool = false
    @State private var isShowingCreate: Bool = false
    
    private var trades = DummyTrade().trades
    @State private var filteredTrades: [Trade] = []

    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @State var category: ANBDCategory = .nanua
    @State private var isGoingToSearchView: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 45)
                
                TabView(selection: $category) {
                    TradeListView(category: .nanua)
                        .tag(ANBDCategory.nanua)
                    
                    TradeListView(category: .baccua)
                        .tag(ANBDCategory.baccua)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            Button(action: {
                isShowingCreate.toggle()
            }, label: {
                WriteButtonView()
            })
        }//ZStack
        .sheet(isPresented: $isShowingCategory) {
            CategoryBottomSheet(isShowingCategory: $isShowingCategory)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $isShowingLocation) {
            LocationBottomSheet(isShowingLocation: $isShowingLocation)
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $isShowingCreate) {
            TradeCreateView(isShowingCreate: $isShowingCreate)
        }
        .navigationTitle("나눔 · 거래")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
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
        .onDisappear {
            tradeViewModel.selectedLocations = []
            tradeViewModel.selectedItemCategories = []
        }
        .navigationDestination(isPresented: $isGoingToSearchView) {
            SearchView()
        }
    }
}

#Preview {
    TradeView()
}
