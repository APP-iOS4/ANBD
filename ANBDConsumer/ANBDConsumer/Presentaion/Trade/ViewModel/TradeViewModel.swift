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
    @Published var tradePath: NavigationPath = NavigationPath()
    
    /// 필터링 옵션 : Location · ItemCateogry
    @Published var selectedLocations: Set<Location> = []
    @Published var selectedItemCategories: Set<ItemCategory> = []
    
    @Published private(set) var trades: [Trade] = []
    @Published private(set) var filteredTrades: [Trade] = []
    
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
}
