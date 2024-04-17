//
//  HomeViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import SwiftUI
import ANBDModel

@MainActor
final class HomeViewModel: ObservableObject {
    private let storageManager = StorageManager.shared
    private let articleUsecase: ArticleUsecase = DefaultArticleUsecase()
    private let tradeUsecase: TradeUsecase = DefaultTradeUsecase()
    private let bannerUsecase: BannerUsecase = DefaultBannerUsecase()
    
    @Published var homePath: NavigationPath = NavigationPath()
    
    @Published var bannerItemList: [Banner] = []
    
    @Published var accuaArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", thumbnailImagePath: "", imagePaths: [])
    @Published var dasiArticle: Article = .init(writerID: "", writerNickname: "", category: .accua, title: "",content: "", thumbnailImagePath: "", imagePaths: [])
    
    @Published var nanuaTrades: [Trade] = []
    @Published var baccuaTrades: [Trade] = []
    
    
    /// 광고 · 배너 가져오기
    func loadBanners() async {
        do {
            try await bannerItemList = bannerUsecase.loadBannerList()
        } catch {
            
        }
    }
    
    /// 아껴쓰기 · 다시쓰기 최신 1개씩 가져오기
    func loadArticle(category: ANBDCategory) async {
        do {
            if category == .accua {
                try await accuaArticle = articleUsecase.loadRecentArticle(category: .accua)
            } else if category == .dasi {
                try await dasiArticle = articleUsecase.loadRecentArticle(category: .dasi)
            }
        } catch {
            
        }
    }
    
    /// 나눠쓰기 · 바꿔쓰기 최신순으로 각각 4개, 2개씩 가져오기
    func loadTrades(category: ANBDCategory) async {
        do {
            if category == .nanua {
                try await nanuaTrades = tradeUsecase.loadRecentTradeList(category: .nanua)
            } else if category == .baccua {
                try await baccuaTrades = tradeUsecase.loadRecentTradeList(category: .baccua)
            }
        } catch {
            
        }
    }
    
    /// 이미지 다운로드
    func loadThumnailImage(path: StoragePath, containerID: String, imagePath: String) async throws -> Data {
        do {
            return try await storageManager.downloadImage(path: path, containerID: "\(containerID)/thumbnail", imagePath: imagePath)
        } catch {
            print("HomeViewModel Error loadImage : \(error) \(error.localizedDescription)")

            /// 이미지 예외 처리
            let image = UIImage(named: "ANBDWarning")
            let imageData = image?.pngData()
            return imageData ?? Data()
        }
    }
}
