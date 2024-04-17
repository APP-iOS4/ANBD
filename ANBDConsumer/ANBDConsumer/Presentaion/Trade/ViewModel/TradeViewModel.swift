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
    private let storageManager = StorageManager.shared
    private let tradeUseCase: TradeUsecase = DefaultTradeUsecase()
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
    
    func getOneTrade(trade: Trade) {
        self.trade = trade
    }
    
    
    
    //read
    func loadAllTrades() async {
        do {
            try await self.trades.append(contentsOf: tradeUseCase.loadTradeList(limit: 10))
            print("read")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func reloadAllTrades() async {
        do {
            print("read")
            self.trades = try await tradeUseCase.refreshAllTradeList(limit: 10)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadOneTrade(trade: Trade) async {
        do {
            self.trade = try await tradeUseCase.loadTrade(tradeID: trade.id)
        } catch {
            print("trade 하나 불러오기 실패: \(error.localizedDescription)")
        }
    }
    
    func loadDetailImages(path: StoragePath, containerID: String, imagePath: [String]) async throws -> [Data] {
        var detailImages: [Data] = []
        
        for image in imagePath {
            do {
                detailImages.append( 
                    try await storageManager.downloadImage(path: path, containerID: containerID, imagePath: image)
                )
            } catch {
                print(error.localizedDescription)
                
                //이미지 예외
                let image = UIImage(named: "ANBDWarning")
                let imageData = image?.pngData()
                detailImages.append( imageData ?? Data() )
            }
        }
        
        return detailImages
    }
    
    //create
    func createTrade(category: ANBDCategory, itemCategory: ItemCategory, location: Location, title: String, content: String, myProduct: String, wantProduct: String?, images: [Data]) async {
        
        let user = UserDefaultsClient.shared.userInfo
        let newTrade: Trade
        
        if let want = wantProduct {
            newTrade = Trade(writerID: user!.id, writerNickname: user!.nickname, category: category, itemCategory: itemCategory, location: location, title: title, content: content, myProduct: myProduct, wantProduct: want, thumbnailImagePath: "", imagePaths: [])
        } else {
            newTrade = Trade(writerID: user!.id, writerNickname: user!.nickname, category: category, itemCategory: itemCategory, location: location, title: title, content: content, myProduct: myProduct, thumbnailImagePath: "", imagePaths: [])
        }
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in images {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        //저장
        do {
            try await tradeUseCase.writeTrade(trade: newTrade, imageDatas: newImages)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //delete
    func deleteTrade(trade: Trade) async {
        do {
            try await tradeUseCase.deleteTrade(trade: trade)
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }
    
    //update -> 아직 안됨 
    func updateTrade(category: ANBDCategory, itemCategory: ItemCategory, location: Location, title: String, content: String, myProduct: String, wantProduct: String?, images: [Data]) async {
        
        self.trade.category = category
        self.trade.itemCategory = itemCategory
        self.trade.location = location
        self.trade.title = title
        self.trade.content = content
        self.trade.myProduct = myProduct
        self.trade.wantProduct = wantProduct
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in images {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
            try await tradeUseCase.updateTrade(trade: self.trade, imageDatas: newImages)
        } catch {
            print("수정 실패: \(error.localizedDescription)")
        }
    }
    
    func updateState(trade: Trade) async {
        
        do {
            try await tradeUseCase.updateTradeState(tradeID: trade.id, tradeState: trade.tradeState)
        } catch {
            print("상태수정 실패: \(error.localizedDescription)")
        }
    }
}
