//
//  BannerRepository.swift
//  
//
//  Created by 유지호 on 4/9/24.
//

import Foundation

@available(iOS 15.0, *)
protocol BannerRepository {
    func createBanner(banner: Banner) async throws
    func readBannerList() async throws -> [Banner]
    func updateBanner(banner: Banner) async throws
    func deleteBanner(bannerID: String) async throws
}
