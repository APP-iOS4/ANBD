//
//  TradeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import ANBDModel
import SwiftUI

@MainActor
final class TradeViewModel: ObservableObject {
    private var tradeUseCase: TradeUsecase = DefaultTradeUsecase()
    @Published var tradePath: NavigationPath = NavigationPath()
    
    /// 필터링 옵션 : Location · ItemCateogry
    @Published var selectedLocations: Set<Location> = []
    @Published var selectedItemCategories: Set<ItemCategory> = []
    
    @Published private(set) var trades: [Trade] = []
    @Published private(set) var filteredTrades: [Trade] = []
    @Published private(set) var trade: Trade = Trade(id: "", writerID: "", writerNickname: "", createdAt: Date(), category: .nanua, itemCategory: .beautyCosmetics, location: .busan, tradeState: .trading, title: "", content: "", myProduct: "", wantProduct: nil, thumbnailImagePath: "", imagePaths: [])
    
    @Published var selectedItemCategory: ItemCategory = .digital
    @Published var selectedLocation: Location = .seoul
    
    
    init() {
        
    }
    
    func filteringTrades(category: ANBDCategory) {
        filteredTrades = trades.filter({ $0.category == category })
        
        if selectedLocations.isEmpty && selectedItemCategories.isEmpty {
            filteredTrades = filteredTrades
        } else if !selectedLocations.isEmpty && !selectedItemCategories.isEmpty {
            filteredTrades = filteredTrades.filter({ selectedItemCategories.contains($0.itemCategory) &&  selectedLocations.contains($0.location) })
        } else {
            filteredTrades = filteredTrades.filter({ selectedItemCategories.contains($0.itemCategory) ||  selectedLocations.contains($0.location) })
        }
    }
    
    func pickerItemCategory(itemCategory: ItemCategory) {
        self.selectedItemCategory = itemCategory
    }
    
    func pickerLocation(location: Location) {
        self.selectedLocation = location
    }
    
    //read
    func loadAllTrades() async {
        do {
            try await self.trades = tradeUseCase.loadTradeList(limit: 15)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //create
    func createTrade(writerID: String, writerNickname: String, category: ANBDCategory, itemCategory: ItemCategory, location: Location, title: String, content: String, myProduct: String, images: [Data]) async {
        
        let newTrade = Trade(writerID: writerID, writerNickname: writerNickname, category: category, itemCategory: itemCategory, location: location, title: title, content: content, myProduct: myProduct, thumbnailImagePath: "", imagePaths: [])
        
        do {
            try await tradeUseCase.writeTrade(trade: newTrade, imageDatas: images)
        } catch {
            print(error.localizedDescription)
        }
    }
}
