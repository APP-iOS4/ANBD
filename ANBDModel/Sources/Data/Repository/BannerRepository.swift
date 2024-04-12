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
    
    let bannerDB = Firestore.firestore().collection("Banner")
    
    init() { }
    
    func createBanner(banner: Banner) async throws {
        guard let _ = try? bannerDB.document(banner.id).setData(from: banner)
        else {
            throw DBError.updateDocumentError(message: "Banner document를 추가하는데 실패했습니다.")
        }
    }
    
    func readBannerList() async throws -> [Banner] {
        guard let snapshot = try? await bannerDB
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents
        else {
            throw DBError.updateDocumentError(message: "Banner document 목록을 불러오는데 실패했습니다.")
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
            throw DBError.updateDocumentError(message: "Banner document를 업데이트하는데 실패했습니다.")
        }
    }
    
    func deleteBanner(bannerID: String) async throws {
        guard let _ = try? await bannerDB.document(bannerID).delete()
        else {
            throw DBError.deleteDocumentError(message: "ID가 일치하는 Banner document를 삭제하는데 실패했습니다.")
        }
    }
    
}
