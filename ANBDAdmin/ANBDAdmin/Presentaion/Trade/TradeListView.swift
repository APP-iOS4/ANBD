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
    @State private var searchTradeText = ""
    @State private var showOnlySearchedTrade:Bool = false
    
    var body: some View {
        VStack {
            TextField("제목이나 ID값으로 검색...", text: $searchTradeText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onSubmit {
                    showOnlySearchedTrade = true
                    if !searchTradeText.isEmpty {
                        Task {
                            tradeListViewModel.tradeList = []
                            await tradeListViewModel.searchTrade(tradeID: searchTradeText)
                        }
                    }
                }
                .textInputAutocapitalization(.characters)// 항상 대문자로 입력받음
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("제목")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자 닉네임")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("생성일자")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView {
                LazyVStack{
                    ForEach(tradeListViewModel.tradeList, id: \.id) { trade in
                        NavigationLink(destination: TradeListDetailView(trade: trade, deletedTradeID: $tradeListViewModel.deletedTradeID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(trade.title)")
                                        .font(.title3)
                                        .lineLimit(1)
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(trade.writerNickname)")
                                        .lineLimit(2)
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(DateFormatterSingleton.shared.dateFormatter(trade.createdAt))")
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Spacer()
                            }
                            .background(Color("DefaultCellColor"))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    if !tradeListViewModel.tradeList.isEmpty {
                        Text("List End")
                            .foregroundColor(.gray)
                            .onAppear {
                                if showOnlySearchedTrade == false {
                                    tradeListViewModel.loadMoreTrades()
                                }
                            }
                    }
                }
                .onAppear {
                    tradeListViewModel.firstLoadTrades()
                }
                .navigationBarTitle("거래글 목록")
                .toolbar {
                    Button(action: {
                        showOnlySearchedTrade = false
                        self.searchTradeText = ""
                        tradeListViewModel.tradeList = []
                        tradeListViewModel.firstLoadTrades()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}
