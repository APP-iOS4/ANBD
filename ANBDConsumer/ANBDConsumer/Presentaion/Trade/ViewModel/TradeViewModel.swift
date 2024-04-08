//
//  TradeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import ANBDModel

@MainActor
final class TradeViewModel: ObservableObject {
    
    //ItemCategory
    @Published private(set) var selectedItemCategories: [ItemCategory] = []
    @Published var isSelectedItemCategories: [Bool] = Array(repeating: false, count: ItemCategory.allCases.count)
    //Location
    @Published private(set) var selectedLocations: [Location] = []
    @Published var isSelectedLocations: [Bool] = Array(repeating: false, count: Location.allCases.count)
    
    init() {
        
    }
    
}
