//
//  SwiftUIView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/11/24.
//

import SwiftUI
import ANBDModel

struct TradeListDetailView: View {
    @Environment(\.presentationMode) var tradepresentationMode
    let trade: Trade
    let tradeUsecase = DefaultTradeUsecase()
    @Binding var deletedTradeID: String?
    
    var body: some View {
        List {
            Text("제목:").foregroundColor(.gray) + Text(" \(trade.title)")
            Text("게시물ID:").foregroundColor(.gray) + Text(" \(trade.id)")
            Text("작성자 닉네임:").foregroundColor(.gray) + Text(" \(trade.writerNickname)")
            Text("작성자 ID:").foregroundColor(.gray) + Text(" \(trade.writerID)")
            Text("생성일자:").foregroundColor(.gray) + Text(" \(dateFormatter(trade.createdAt))")
            Text("카테고리:").foregroundColor(.gray) + Text(" \(trade.category)")
            Text("내 물건:").foregroundColor(.gray) + Text(" \(trade.myProduct)")
            Text("바꾸고 싶은 물건:").foregroundColor(.gray) + Text(" \(String(describing: trade.wantProduct))")
            Text("내용:").foregroundColor(.gray) + Text(" \(trade.content)")
            Text("이미지:").foregroundColor(.gray) + Text(" \(trade.imagePaths )")
        }
        .navigationBarTitle(trade.title)
        .toolbar {
            Button("Delete") {
                Task {
                    do {
                        try await tradeUsecase.deleteTrade(trade: trade)
                        deletedTradeID = trade.id
                        tradepresentationMode.wrappedValue.dismiss()
                    } catch {
                        print("게시물을 삭제하는데 실패했습니다: \(error)")
                    }
                }
            }
        }
    }
}

