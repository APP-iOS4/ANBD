//
//  TradeListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/12/24.
//

import Foundation
import SwiftUI
import ANBDModel

class TradeListViewModel: ObservableObject {
    @Published var tradeList: [Trade] = []
    var deletedTradeID: String? // 삭제 변수
    let tradeUsecase = DefaultTradeUsecase()

    func loadTrades() {
        if tradeList.isEmpty || tradeList.contains(where: { $0.id == deletedTradeID })  {
            Task {
                do {
                    let trades = try await tradeUsecase.loadTradeList()
                                    DispatchQueue.main.async {
                                        self.tradeList = trades
                                    }
                } catch {
                    print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
}
