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
    
    /// 필터링 옵션 : Location · ItemCateogry
    @Published var selectedLocations: Set<Location> = []
    @Published var selectedItemCategories: Set<ItemCategory> = []
    
    @Published private(set) var filteredTrades: [Trade] = []
    
    @Published var selectedItemCategory: ItemCategory = .digital
    @Published var selectedLocation: Location = .seoul
    
    let mockTradeData: [Trade] = [
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .beautyCosmetics, location: .busan, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyImage1"]),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .sportsLeisure, location: .jeju, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy1"]),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy2"]),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: ["DummyPuppy3"]),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .baccua, itemCategory: .digital, location: .seoul, title: "바꿉니다용", content: "바꿉니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: [])
    ]
    
    init() {
        filteredTrades = mockTradeData
    }
    
    
    func filteringTrades(category: ANBDCategory) {
        filteredTrades = mockTradeData.filter({ $0.category == category })
        
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
