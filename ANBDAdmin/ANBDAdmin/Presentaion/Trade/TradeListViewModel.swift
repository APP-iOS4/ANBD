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

    func firstLoadTrades() {
        if tradeList.isEmpty {
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
    func loadTrade(tradeID: String) async throws -> Trade {
        return try await tradeUsecase.loadTrade(tradeID: tradeID)
    }
    func searchTrade(tradeID: String) async {
        do {
            let searchedTrade = try await loadTrade(tradeID: tradeID)
            DispatchQueue.main.async {
                self.tradeList = [searchedTrade]
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.tradeList = []
            }
        }
    }
}
