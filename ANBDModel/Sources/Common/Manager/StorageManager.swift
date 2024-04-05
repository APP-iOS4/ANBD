//
//  StorageManager.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseStorage

enum StoragePath: String {
    case article = "Article"
    case trade = "Trade"
    case profile = "Profile"
}

@available(iOS 13, *)
struct StorageManager {
    let storageRef = Storage.storage().reference()
    private let storageMetadata = StorageMetadata()
    
    static let shared = StorageManager()
    
    private init() {
        storageMetadata.contentType = "image/jpeg"
    }
 
    
    /// Image를 FirebaseStorage에 저장하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageDatas: 저장할 Image의 Data
    /// - Returns: 저장에 성공할 시 FirebaseStorage 상 ImageID를 반환한다.
    public func uploadImage(
        path storagePath: StoragePath,
        containerID: String,
        imageData: Data
    ) async throws -> String {
        let imageID = "\(UUID().uuidString).jpeg"
        
        guard let _ = try? await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .child(imageID)
            .putDataAsync(imageData, metadata: storageMetadata)
        else {
            throw StorageError.uploadError
        }
        
        return imageID
    }
    
    
    /// Image를 FirebaseStorage에 저장하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageDatas: 저장할 Image의 Data 배열
    /// - Returns: 저장에 성공할 시 FirebaseStorage 상 ImageID 배열을 반환한다.
    public func uploadImageList(
        path storagePath: StoragePath,
        containerID: String,
        imageDatas: [Data]
    ) async throws -> [String] {
        var imageIDs: [String] = []
        
        for imageData in imageDatas {
            let imageID = try await uploadImage(path: storagePath, containerID: containerID, imageData: imageData)
            imageIDs.append(imageID)
        }
        
        return imageIDs
    }
    
    
    /// Image를 수정하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageID: 수정하려는 Image의 ID
    ///   - imageData: 수정할 Image의 Data
    public func updateImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String,
        imageData: Data
    ) async throws {
        guard let _ = try? await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .child(imagePath)
            .putDataAsync(imageData, metadata: storageMetadata)
        else {
            throw StorageError.updateError
        }
    }
    
    
    /// Image 배열을 수정하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageID: 수정하려는 Image의 ID
    ///   - imageDatas: 수정할 Image의 Data 배열
    public func updateImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String],
        imageDatas: [Data]
    ) async throws {
        for (imagePath, imageData) in zip(imagePaths, imageDatas) {
            try await updateImage(path: storagePath, containerID: containerID, imagePath: imagePath, imageData: imageData)
        }
    }
    
    
    /// Image를 FirebaseStorage에서 불러오는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 불러오려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담은 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageURL: 저장한 Image의 URL
    public func downloadImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            storageRef
                .child(storagePath.rawValue)
                .child(containerID)
                .child(imagePath)
                .getData(maxSize: 1 * 1024 * 1024) { result in
                    switch result {
                    case .success(let imageData):
                        continuation.resume(returning: imageData)
                    case .failure:
                        continuation.resume(throwing: StorageError.downloadError)
                    }
                }
        }
    }
    
    
    /// Image를 FirebaseStorage에서 불러오는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 불러오려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담은 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageURLs: 저장한 Image들의 URL 배열
    public func downloadImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String]
    ) async throws -> [Data] {
        var imageDatas: [Data] = []
        
        for imagePath in imagePaths {
            let imageData = try await downloadImage(path: storagePath, containerID: containerID, imagePath: imagePath)
            imageDatas.append(imageData)
        }
        
        return imageDatas
    }
    
    
    
    public func deleteImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String
    ) async throws {
        guard let _ = try? await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .child(imagePath)
            .delete()
        else {
            throw StorageError.deleteError
        }
    }
    
    
    
    public func deleteImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String]
    ) async throws {
        for imagePath in imagePaths {
            try await deleteImage(path: storagePath, containerID: containerID, imagePath: imagePath)
        }
    }
}
