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
    @State var category: Category = .nanua
//    @State var region:
    @State var itemCategory: [ItemCategory] = []
    @State private var isShowingCategory: Bool = false
    @State var location: [Location] = []
    @State private var isShowingLocation: Bool = false
    
    private var trades = DummyTrade().trades
    @State private var filteredTrades: [Trade] = []
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading) {
                CategoryDividerView(category: $category)
                    .frame(height: 45)
                HStack {
                    // 지역 선택
                    if location.count == 0 {
                        Button(action: {
                            self.isShowingLocation.toggle()
                        }, label: {
                            CapsuleButtonView(text: "지역")
                                .frame(width: 100)
                        })
                    } else if location.count == 1 {
                        Button(action: {
                            self.isShowingLocation.toggle()
                        }, label: {
                            //BlueCapsuleButtonView(text: location.first!.description)
                                //.frame(width: 100)
                        })
                    } else {
                        Button(action: {
                            self.isShowingLocation.toggle()
                        }, label: {
//                            BlueCapsuleButtonView(text: "지역 \(location.count)")
//                                .frame(width: 100)
                        })
                    }
                    
                    // 제품 카테고리 선택
                    if itemCategory.count == 0 {
                        Button(action: {
                            self.isShowingCategory.toggle()
                        }, label: {
                            CapsuleButtonView(text: "카테고리")
                                .frame(width: 100)
                        })
                    } else if itemCategory.count == 1 {
                        Button(action: {
                            self.isShowingCategory.toggle()
                        }, label: {
//                            BlueCapsuleButtonView(text: itemCategory.first!.labelText)
//                                .frame(width: 100)
                        })
                    } else {
                        Button(action: {
                            self.isShowingCategory.toggle()
                        }, label: {
//                            BlueCapsuleButtonView(text: "카테고리 \(itemCategory.count)")
//                                .frame(width: 100)
                        })
                    }
                }//HStack
                .padding()
                
                TabView(selection: $category) {
                    listView
                    listView
                }
            }//VStack
            .onAppear {
                if category == .nanua {
                    filteredTrades = trades.filter { $0.category == .nanua }
                } else {
                    filteredTrades = trades.filter { $0.category == .baccua }
                }
            }
            .onChange(of: category) {
                if category == .nanua {
                    filteredTrades = trades.filter { $0.category == .nanua }
                } else {
                    filteredTrades = trades.filter { $0.category == .baccua }
                }
            }
            
            Button(action: {
                
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
        .navigationTitle("나눔 · 거래")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

extension TradeView {
    var listView: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredTrades, id: \.self) { item in
                    NavigationLink(value: item) {
                        TradeListCell(trade: item)
                            .padding()
                        Divider()
                    }
                }
            }
        }
        .navigationDestination(for: Trade.self) { item in
            TradeDetailView(trade: item)
        }
    }
    
}

