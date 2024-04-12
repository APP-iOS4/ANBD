//
//  TradeListView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct TradeListView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    var category: ANBDCategory = .baccua
    var isFromHomeView: Bool = false
    var searchText: String? = nil
    
    @State private var isShowingLocation: Bool = false
    @State private var isShowingItemCategory: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
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
            .padding(.horizontal)
            
            if tradeViewModel.filteredTrades.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("해당하는 나눔 · 거래 게시글이 없습니다.")
                            .foregroundStyle(.gray400)
                            .font(ANBDFont.body1)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack {
                        
                        ForEach(tradeViewModel.filteredTrades) { trade in
                            VStack {
                                NavigationLink(value: trade) {
                                    TradeListCell(trade: trade)
                                        .padding(.vertical, 5)
                                }
                                Divider()
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                    .background(.white)
                    .padding(.bottom, 80)
                }
                .background(.gray50)
                .navigationDestination(for: Trade.self) { item in
                    TradeDetailView(trade: item)
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(isFromHomeView ? .hidden : .visible, for: .tabBar)
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

extension TradeListView {
    private var navigationTitle: String {
        if let searchText = searchText {
            return searchText
        } else if isFromHomeView {
            return category.description
        } else {
            return "나눔 · 거래"
        }
    }
}

#Preview {
    TradeListView()
        .environmentObject(TradeViewModel())
}
