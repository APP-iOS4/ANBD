//
//  DefaultBannerRepository.swift
//
//
//  Created by 유지호 on 4/9/24.
//

import Foundation
import FirebaseFirestore

@available(iOS 15.0, *)
struct DefaultBannerRepository: BannerRepository {
    
    private let bannerDB = Firestore.firestore().collection("Banner")
    
    init() { }
    
    func createBanner(banner: Banner) async throws {
        guard let _ = try? bannerDB.document(banner.id).setData(from: banner)
        else {
            throw DBError.setBannerDocumentError
        }
    }
    
    func readBannerList() async throws -> [Banner] {
        guard let snapshot = try? await bannerDB
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.getBannerDocumentError
        }
        
        let bannerList = snapshot.compactMap { try? $0.data(as: Banner.self) }
        
        return bannerList
    }
    
    func updateBanner(banner: Banner) async throws {
        guard let _ = try? await bannerDB.document(banner.id).updateData([
            "createdAt": banner.createdAt,
            "urlString": banner.urlString,
            "thumbnailImageURLString": banner.thumbnailImageURLString
        ])
        else {
            throw DBError.updateBannerDocumentError
        }
    }
    
    func deleteBanner(bannerID: String) async throws {
        guard let _ = try? await bannerDB.document(bannerID).delete()
        else {
            throw DBError.deleteBannerDocumentError
        }
    }
    
}
