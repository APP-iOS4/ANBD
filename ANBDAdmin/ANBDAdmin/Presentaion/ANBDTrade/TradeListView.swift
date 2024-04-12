//
//  SwiftUIView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/11/24.
//

import SwiftUI
import ANBDModel

struct TradeListView: View {
    @StateObject private var tradeListViewModel = TradeListViewModel()
    @State private var searchTradeText = "" // 검색 텍스트 추적하는 변수
    
    var body: some View {
        VStack {
            TextField("검색...", text: $searchTradeText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            List {
                ForEach(tradeListViewModel.tradeList.filter({ searchTradeText.isEmpty ? true : $0.title.contains(searchTradeText) }), id: \.id) { trade in
                    NavigationLink(destination: TradeListDetailView(trade: trade, deletedTradeID: $tradeListViewModel.deletedTradeID)) {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("제목")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(trade.title)")
                                    .font(.title3)
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("작성자 닉네임")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(trade.writerNickname)")
                            }
                            .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text("생성일자")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(dateFormatter(trade.createdAt))")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Spacer()
                        }
                    }
                }
            }
            
            .onAppear {
                tradeListViewModel.loadTrades()
            }
            .navigationBarTitle("거래글 목록")
        }
    }
}
