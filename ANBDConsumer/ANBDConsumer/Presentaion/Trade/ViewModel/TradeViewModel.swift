//
//  TradeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import ANBDModel
import SwiftUI

final class TradeViewModel: ObservableObject {
    private let storageManager = StorageManager.shared
    private let tradeUseCase: TradeUsecase = DefaultTradeUsecase()
    
    /// 필터링 옵션 : Location · ItemCateogry
    @Published var selectedLocations: [Location] = []
    @Published var selectedItemCategories: [ItemCategory] = []
    
    @Published private(set) var trades: [Trade] = []
    @Published var filteredTrades: [Trade] = []
    @Published var trade: Trade = Trade(id: "", writerID: "", writerNickname: "", createdAt: Date(), category: .nanua, itemCategory: .beautyCosmetics, location: .busan, tradeState: .trading, title: "", content: "", myProduct: "", wantProduct: nil, thumbnailImagePath: "", imagePaths: [])
    
    @Published var selectedItemCategory: ItemCategory = .digital
    @Published var selectedLocation: Location = .seoul
    
    //MARK: - 로컬 함수 (네트워크 호출 X)
    
    func pickerItemCategory(itemCategory: ItemCategory) {
        self.selectedItemCategory = itemCategory
    }
    
    func pickerLocation(location: Location) {
        self.selectedLocation = location
    }
    
    func getOneTrade(trade: Trade) {
        self.trade = trade
    }
    
    //MARK: - READ
    
    /// 위로 당겨서 새로고침 + 지역, 카테고리가 바뀌었을 경우 호출
    @MainActor
    func reloadFilteredTrades(category: ANBDCategory) async {
        do {
            if self.selectedLocations.isEmpty && self.selectedItemCategories.isEmpty {
                print("둘다 엠티여요")
                
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: nil, itemCategory: nil, limit: 8)
                
                //print("🥹\(filteredTrades)")
                
            } else if self.selectedLocations.isEmpty {
                print("지역 엠티여요")
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: nil, itemCategory: self.selectedItemCategories, limit: 8)
                
            } else if self.selectedItemCategories.isEmpty {
                print("카테고리 엠티여요")
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: nil, limit: 8)
                
            } else {
                print("둘다 풀")
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: self.selectedItemCategories, limit: 8)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 페이지네이션시 호출
    @MainActor
    func loadMoreFilteredTrades(category: ANBDCategory) async {
        do {
            var newTrades: [Trade] = []
            if self.selectedLocations.isEmpty && self.selectedItemCategories.isEmpty {
                //print("둘다 엠티여요")
                newTrades = try await tradeUseCase.loadFilteredTradeList(category: category, location: nil, itemCategory: nil, limit: 5)
            } else if self.selectedLocations.isEmpty {
                //print("지역 엠티여요")
                newTrades = try await tradeUseCase.loadFilteredTradeList(category: category, location: nil, itemCategory: self.selectedItemCategories, limit: 5)
            } else if self.selectedItemCategories.isEmpty {
                //print("카테고리 엠티여요")
                newTrades = try await tradeUseCase.loadFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: nil, limit: 5)
            } else {
                //print("둘다 풀")
                newTrades = try await tradeUseCase.loadFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: self.selectedItemCategories, limit: 5)
            }
            
            for item in newTrades {
                if filteredTrades.contains(item) {
                    print("end")
                } else {
                    self.filteredTrades.append(contentsOf: newTrades)
                }
            }
                
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 뷰모델에 하나의 trade 값 저장
    @MainActor
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
    
    //MARK: - CREATE
    
    func createTrade(category: ANBDCategory, itemCategory: ItemCategory, location: Location, title: String, content: String, myProduct: String, wantProduct: String, images: [Data]) async {
        
        let user = UserStore.shared.user
        var want: String = ""
        
        if wantProduct == "" {
            want = "제시"
        } else {
            want = wantProduct
        }
        
        let newTrade = Trade(writerID: user.id, writerNickname: user.nickname, category: category, itemCategory: itemCategory, location: location, title: title, content: content, myProduct: myProduct, wantProduct: want, thumbnailImagePath: "", imagePaths: [])
        
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
    
    //MARK: - DELETE
    
    func deleteTrade(trade: Trade) async {
        do {
            try await tradeUseCase.deleteTrade(trade: trade)
        } catch {
            print("삭제 실패: \(error.localizedDescription)")
        }
    }
    
    //MARK: - UPDATE
    
    @MainActor
    func updateTrade(category: ANBDCategory, title: String, content: String, myProduct: String, wantProduct: String, images: [Data]) async {
        
        self.trade.category = category
        self.trade.itemCategory = self.selectedItemCategory
        self.trade.location = self.selectedLocation
        self.trade.title = title
        self.trade.content = content
        self.trade.myProduct = myProduct
        if wantProduct != "" {
            self.trade.wantProduct = wantProduct
        } else {
            self.trade.wantProduct = "제시"
        }
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in images {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
            try await tradeUseCase.updateTrade(trade: self.trade, imageDatas: newImages)
            trade = try await tradeUseCase.loadTrade(tradeID: trade.id)
        } catch {
            print("수정 실패: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateState(trade: Trade) async {
        
        do {
            self.trade = trade
            if self.trade.tradeState == .trading {
                try await tradeUseCase.updateTradeState(tradeID: self.trade.id, tradeState: .finish)
                self.trade.tradeState = .finish
            } else {
                try await tradeUseCase.updateTradeState(tradeID: self.trade.id, tradeState: .trading)
                self.trade.tradeState = .trading
            }
        } catch {
            print("상태수정 실패: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func updateLikeTrade(trade: Trade) async {
        do {
            try await tradeUseCase.likeTrade(tradeID: trade.id)
            guard let userID = UserDefaultsClient.shared.userID else { return }
            UserStore.shared.user = await UserStore.shared.getUserInfo(userID: userID)
        } catch {
            print("좋아요 실패: \(error.localizedDescription)")
        }
    }
}
