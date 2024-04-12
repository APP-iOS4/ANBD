//
//  SwiftUIView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/11/24.
//

import SwiftUI
import ANBDModel

struct TradeListView: View {
    @State private var tradeList: [Trade] = []
    @State private var deletedTradeID: String? // 삭제 상태 변수
    let tradeUsecase = DefaultTradeUsecase()
    
    var body: some View {
        List {
            ForEach(tradeList, id: \.id) { trade in
                NavigationLink(destination: TradeListDetailView(trade: trade, deletedTradeID: $deletedTradeID)) {
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
                .listRowBackground(
                    Capsule()
                        .fill(Color.white)
                )
            }
        }

        .onAppear {
            if tradeList.isEmpty || tradeList.contains(where: { $0.id == deletedTradeID }) {
                Task {
                    do {
                        self.tradeList = try await tradeUsecase.loadTradeList()
                    } catch {
                        print("거래글 목록을 가져오는데 실패했습니다: \(error)")
                    }
                }
            }
        }
        .navigationBarTitle("거래글 목록")
    }
}

