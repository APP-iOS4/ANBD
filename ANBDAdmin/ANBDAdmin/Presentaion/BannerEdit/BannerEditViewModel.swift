//
//  BannerEditViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/16/24.
//

import Foundation
import ANBDModel

class BannerEditViewModel: ObservableObject {
    
    @Published var bannerList: [Banner] = []
    var deletedBannerID: String? // 삭제 변수
    let bannerUsecase = DefaultBannerUsecase()
    

    func loadBanners() {
        if bannerList.isEmpty || bannerList.contains(where: { $0.id == deletedBannerID })  {
            Task {
                do {
                    let banners = try await bannerUsecase.loadBannerList()
                                    DispatchQueue.main.async {
                                        self.bannerList = banners
                                    }
                } catch {
                    print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func addBanner(banner: Banner) async throws {
        try await bannerUsecase.addBanner(banner: banner)
    }
}
