//
//  TradeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import ANBDModel
import SwiftUI
import PhotosUI

final class TradeViewModel: ObservableObject {
    private let storageManager = StorageManager.shared
    private let tradeUseCase: TradeUsecase = DefaultTradeUsecase()
    private let userUseCase: UserUsecase = DefaultUserUsecase()
    
    /// 필터링 옵션 : Location · ItemCateogry
    @Published var selectedLocations: [Location] = []
    @Published var selectedItemCategories: [ItemCategory] = []
    
    @Published private(set) var trades: [Trade] = []
    @Published var filteredTrades: [Trade] = []
    @Published var trade: Trade = Trade(id: "", writerID: "", writerNickname: "", createdAt: Date(), category: .nanua, itemCategory: .beautyCosmetics, location: .busan, tradeState: .trading, title: "", content: "", myProduct: "", wantProduct: nil, thumbnailImagePath: "", imagePaths: [])
    
    @Published var selectedItemCategory: ItemCategory = .digital
    @Published var selectedLocation: Location = .seoul
    @Published var detailImages: [Data] = []
    
    @State private var isDone: Bool = false
    
    //MARK: - 로컬 함수 (네트워크 호출 X)
    
    func filteringTrades(category: ANBDCategory) {
        self.filteredTrades = trades.filter({ $0.category == category })
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
    
    //MARK: - READ
    
    /// 위로 당겨서 새로고침 + 지역, 카테고리가 바뀌었을 경우 호출
    @MainActor
    func reloadFilteredTrades(category: ANBDCategory) async {
        do {
            if self.selectedLocations.isEmpty && self.selectedItemCategories.isEmpty {
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: nil, itemCategory: nil, limit: 8)
                
            } else if self.selectedLocations.isEmpty {
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: nil, itemCategory: self.selectedItemCategories, limit: 8)
                
            } else if self.selectedItemCategories.isEmpty {
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: nil, limit: 8)
                
            } else {
                self.filteredTrades = try await tradeUseCase.refreshFilteredTradeList(category: category, location: self.selectedLocations, itemCategory: self.selectedItemCategories, limit: 8)
            }
            self.filteredTrades = self.filteredTrades.filter { $0.tradeState == .trading }
        } catch {
            #if DEBUG
            print("reloadFilteredTrades: \(error)")
            #endif
        }
    }
    
    /// 페이지네이션시 호출
    @MainActor
    func loadMoreFilteredTrades(category: ANBDCategory) async {
        do {
            var newTrades: [Trade] = []
            if self.selectedLocations.isEmpty && self.selectedItemCategories.isEmpty {
                //print("페이지네이션!! 둘다 엠티여요")
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
            
            newTrades = newTrades.filter { $0.tradeState == .trading }
            
            for item in newTrades {
                if !filteredTrades.contains(item) {
                    self.filteredTrades.append(contentsOf: newTrades)
                }
            }
                
        } catch {
            #if DEBUG
            print("loadMoreFilteredTrades: \(error)")
            #endif
        }
    }
    
    /// 뷰모델에 하나의 trade 값 저장
    @MainActor
    func loadOneTrade(trade: Trade) async {
        do {
            self.trade = try await tradeUseCase.loadTrade(tradeID: trade.id)
            self.detailImages = try await loadDetailImages(path: .trade, containerID: self.trade.id, imagePath: self.trade.imagePaths)
        } catch {
            #if DEBUG
            print("trade 하나 불러오기 실패: \(error)")
            #endif
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
                #if DEBUG
                print("loadDetailImages: \(error)")
                #endif
                //이미지 예외
                let image = UIImage(named: "ANBDWarning")
                let imageData = image?.pngData()
                detailImages.append( imageData ?? Data() )
                
                guard let error = error as? StorageError else {
                    ToastManager.shared.toast = Toast(style: .error, message: "사진 불러오기에 실패하였습니다.")
                    return detailImages
                }
                ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
            }
        }
        
        return detailImages
    }
    
    func createImageURL(from imageData: Data) -> URL? {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let imageFileName = "image\(Date().timeIntervalSince1970).jpeg"
        let imageURL = documentsDirectory.appendingPathComponent(imageFileName)

        do {
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            print("\(error.localizedDescription)")
            return nil
        }
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
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("createTrade: \(error)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 작성에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    //MARK: - DELETE
    
    func deleteTrade(trade: Trade) async {
        do {
            try await tradeUseCase.deleteTrade(trade: trade)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("삭제 실패: \(error.localizedDescription)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 삭제에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    //MARK: - UPDATE
    
    @MainActor
    func updateTrade(category: ANBDCategory, title: String, content: String, myProduct: String, wantProduct: String, addImages: [Data], deletedImagesIndex: [Int]) async {
        
        let user = UserStore.shared.user
        let originCategory = self.trade.category
        
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
        
        //삭제된 이미지
        var deletedImages: [String] = []
        for i in deletedImagesIndex {
            deletedImages.append(self.trade.imagePaths[i])
            self.trade.imagePaths.remove(at: i)
        }
        
        //이미지 리사이징
        var newImages: [Data] = []
        for image in addImages {
            let imageData = await UIImage(data: image)?.byPreparingThumbnail(ofSize: .init(width: 1024, height: 1024))?.jpegData(compressionQuality: 0.5)
            newImages.append(imageData ?? Data())
        }
        
        do {
            try await tradeUseCase.updateTrade(trade: self.trade, add: newImages, delete: deletedImages)
            try await userUseCase.updateUserPostCount(user: user, before: originCategory, after: trade.category)
            trade = try await tradeUseCase.loadTrade(tradeID: trade.id)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("수정 실패: \(error)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 수정에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
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
            #if DEBUG
            print("상태수정 실패: \(error)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래 상태 변경에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    @MainActor
    func updateLikeTrade(trade: Trade) async {
        do {
            try await tradeUseCase.likeTrade(tradeID: trade.id)
            await UserStore.shared.updateLocalUserInfo()
        } catch {
            #if DEBUG
            print("좋아요 실패: \(error)")
            #endif
            guard let error = error as? TradeError else {
                ToastManager.shared.toast = Toast(style: .error, message: "거래글 찜하기에 실패하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    //MARK: - SEARCH
    
    @MainActor
    func searchTrade(keyword: String, category: ANBDCategory?) async {
        do {
            trades = try await tradeUseCase.refreshSearchTradeList(keyword: keyword, limit: 100)
            if let category {
                filteringTrades(category: category)
            }
        } catch {
            #if DEBUG
            print("searchTrade: \(error)")
            #endif
        }
    }
}
