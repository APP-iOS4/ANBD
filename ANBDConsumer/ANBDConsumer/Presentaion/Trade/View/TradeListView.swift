//
//  TradeListView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI

struct TradeListView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    var category: Category = .nanua
    
    @State private var isShowingLocation: Bool = false
    @State private var isShowingItemCategory: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    isShowingLocation.toggle()
                }, label: {
                    CapsuleButtonView(text: "지역", isForFiltering: true)
                })
                
                Button(action: {
                    isShowingItemCategory.toggle()
                }, label: {
                    CapsuleButtonView(text: "카테고리", isForFiltering: true)
                })
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack {
                    ForEach(tradeViewModel.mockTradeData) { trade in
                        TradeListCell(trade: trade)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $isShowingLocation) {
            LocationBottomSheet(isShowingLocation: $isShowingLocation)
                .presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $isShowingItemCategory) {
            CategoryBottomSheet(isShowingCategory: $isShowingItemCategory)
                .presentationDetents([.fraction(0.6)])
        }
    }
}

#Preview {
    TradeListView()
        .environmentObject(TradeViewModel())
}
