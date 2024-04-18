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
            TextField("제목이나 ID값으로 검색...", text: $searchTradeText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("제목")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자 닉네임")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 258, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("생성일자")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView {
                LazyVStack{
                    ForEach(tradeListViewModel.tradeList.filter({ searchTradeText.isEmpty ? true : $0.title.contains(searchTradeText) || $0.id.contains(searchTradeText) }), id: \.id) { trade in
                        NavigationLink(destination: TradeListDetailView(trade: trade, deletedTradeID: $tradeListViewModel.deletedTradeID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(trade.title)")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(trade.writerNickname)")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(dateFormatter(trade.createdAt))")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                        }
                    }
                }
                
                .onAppear {
                    tradeListViewModel.loadTrades()
                }
                .navigationBarTitle("거래글 목록")
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}
