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
    var deletedTradeID: String?
    let tradeUsecase = DefaultTradeUsecase()
    @Published var canLoadMoreTrades: Bool = true

    
    func firstLoadTrades() {
        if tradeList.isEmpty {
            Task {
                do {
                    let trades = try await tradeUsecase.refreshAllTradeList(limit: 10)
                    DispatchQueue.main.async {
                        self.tradeList = trades
                        self.canLoadMoreTrades = true
                    }
                } catch {
                    print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func loadMoreTrades(){
        guard canLoadMoreTrades else { return }

        Task {
            do {
                let trades = try await tradeUsecase.loadTradeList(limit: 10)
                DispatchQueue.main.async {
                    self.tradeList.append(contentsOf: trades)
                    if trades.count < 10 {
                        self.canLoadMoreTrades = false
                    }
                }
            } catch {
                print("게시물 목록을 가져오는데 실패했습니다: \(error)")
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
