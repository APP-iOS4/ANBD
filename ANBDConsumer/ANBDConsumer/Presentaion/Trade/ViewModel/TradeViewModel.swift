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
    @Published var selectedLocations: Set<Location> = []
    
    
    @Published private(set) var filteredTrades: [Trade] = []
    
    let mockTradeData: [Trade] = [
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: []),
        .init(writerID: "likelion123", writerNickname: "줄이줄이", category: .nanua, itemCategory: .digital, location: .seoul, title: "나눠요나눠", content: "나눕니다용~~", myProduct: "내꺼 너꺼 내꺼 너꺼", imagePaths: [])
    ]
    
    init() {
        
    }
    
    
    
}
