//
//  TradeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct TradeView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    
    @State private var isShowingCreate: Bool = false
    @State var category: ANBDCategory = .nanua
    @State private var isGoingToSearchView: Bool = false
    
    var body: some View {
        if #available(iOS 17.0, *) {
            wholeView
            .onChange(of: category) {
                tradeViewModel.filteringTrades(category: category)
            }
            .onAppear {
                tradeViewModel.filteringTrades(category: category)
            }
            .fullScreenCover(isPresented: $isShowingCreate) {
                TradeCreateView(isShowingCreate: $isShowingCreate, category: category)
            }
            .navigationTitle("나눔 · 거래")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarRole(.editor)
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
                SearchView(category: category)
            }
        } else {
            wholeView
                .onChange(of: category) { _ in
                    tradeViewModel.filteringTrades(category: category)
                }
                .onAppear {
                    tradeViewModel.filteringTrades(category: category)
                }
                .fullScreenCover(isPresented: $isShowingCreate) {
                    TradeCreateView(isShowingCreate: $isShowingCreate, category: category)
                }
                .navigationTitle("나눔 · 거래")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarRole(.editor)
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
                    SearchView(category: category)
                }
        }
    }
}

extension TradeView {
    fileprivate var wholeView: some View {
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
    }
}

#Preview {
    TradeView()
}
