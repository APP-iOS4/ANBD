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
    
    /// Home에서 보여주는 아이템들
    @Published var bannerItemList: [Banner] = []
    @Published var accuaArticle: Article?
    @Published var dasiArticle: Article?
    @Published var nanuaTrades: [Trade] = []
    @Published var baccuaTrades: [Trade] = []
    
    
    /// 광고 · 배너 가져오기
    func loadBanners() async {
        do {
            try await bannerItemList = bannerUsecase.loadBannerList()
        } catch {
            guard let error = error as? DBError else { return }
            ToastManager.shared.toast = Toast(style: .error, message: error.message)
        }
    }
    
    /// 아껴쓰기 · 다시쓰기 최신 1개씩 가져오기
    func loadArticle(category: ANBDCategory) async {
        do {
            if category == .accua {
                accuaArticle = try await articleUsecase.loadRecentArticle(category: .accua)
            } else if category == .dasi {
                dasiArticle = try await articleUsecase.loadRecentArticle(category: .dasi)
            }
        } catch {
            print("=== ERROR: LOAD ARTICLE ===")
            print("\(error)")
            
            guard let error = error as? ArticleError else { return }
            ToastManager.shared.toast = Toast(style: .error, message: error.message)
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
            guard let error = error as? TradeError else { return }
            ToastManager.shared.toast = Toast(style: .error, message: error.message)
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
            
            guard let error = error as? StorageError else { return imageData ?? Data() }
            ToastManager.shared.toast = Toast(style: .error, message: error.message)
            
            return imageData ?? Data()
        }
    }
}
