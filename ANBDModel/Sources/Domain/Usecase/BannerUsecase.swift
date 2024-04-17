//
//  BannerUsecase.swift
//
//
//  Created by 유지호 on 4/9/24.
//

import Foundation

@available(iOS 15.0, *)
public protocol BannerUsecase {
    func addBanner(banner: Banner) async throws
    func loadBannerList() async throws -> [Banner]
    func updateBannerList(banner: Banner) async throws
    func deleteBanner(bannerID: String) async throws
}

@available(iOS 15.0, *)
public struct DefaultBannerUsecase: BannerUsecase {
    
    private let bannerRepository: BannerRepository = DefaultBannerRepository()
    
    public init() { }
    
    
    /// Banner를 추가하는 메서드
    /// - Parameters:
    ///   - banner: 추가하려는 Banner
    public func addBanner(banner: Banner) async throws {
        if banner.urlString.isEmpty || banner.thumbnailImageURLString.isEmpty {
            return
        }
        
        let banner = Banner(
            urlString: banner.urlString,
            thumbnailImageURLString: banner.thumbnailImageURLString
        )
        try await bannerRepository.createBanner(banner: banner)
    }
    
    
    /// Banner 목록을 반환하는 메서드
    /// - Returns: Banner 배열
    public func loadBannerList() async throws -> [Banner] {
        try await bannerRepository.readBannerList()
    }
    
    
    /// Banner를 수정하는 메서드
    /// - Parameters:
    ///   - banner: 수정한 Banner
    public func updateBannerList(banner: Banner) async throws {
        try await bannerRepository.updateBanner(banner: banner)
    }
    
    
    /// Banner를 삭제하는 메서드
    /// - Parameters:
    ///   - bannerID: 삭제하려는 Banner의 ID
    public func deleteBanner(bannerID: String) async throws {
        try await bannerRepository.deleteBanner(bannerID: bannerID)
    }
    
}
