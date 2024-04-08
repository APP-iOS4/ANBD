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
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @State var category: ANBDCategory = .nanua
    
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
                
            }, label: {
                WriteButtonView()
            })
        }//ZStack
        .navigationTitle("나눔 · 거래")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

#Preview {
    TradeView(category: .nanua)
        .environmentObject(TradeViewModel())
}
