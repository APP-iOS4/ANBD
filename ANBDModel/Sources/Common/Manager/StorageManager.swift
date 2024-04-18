//
//  StorageManager.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import SwiftUI
import FirebaseStorage

public enum StoragePath: String {
    case article = "Article"
    case trade = "Trade"
    case profile = "Profile"
    case chat = "Chat"
}

@available(iOS 15, *)
public struct StorageManager {
    let storageRef = Storage.storage().reference()
    private let storageMetadata = StorageMetadata()
    
    public static let shared = StorageManager()
    
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
    @discardableResult
    public func uploadImage(
        path storagePath: StoragePath,
        containerID: String,
        imageData: Data
    ) async throws -> String {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        let imagePath = "\(UUID().uuidString).jpeg"
        
        guard let _ = try? await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .child(imagePath)
            .putDataAsync(imageData, metadata: storageMetadata)
        else {
            throw StorageError.uploadError
        }
        
        return imagePath
    }
    
    
    /// Image를 FirebaseStorage에 저장하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imageDatas: 저장할 Image의 Data 배열
    /// - Returns: 저장에 성공할 시 FirebaseStorage 상 ImageID 배열을 반환한다.
    @discardableResult
    public func uploadImageList(
        path storagePath: StoragePath,
        containerID: String,
        imageDatas: [Data]
    ) async throws -> [String] {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imageDatas.isEmpty {
            throw StorageError.invalidImageData
        }
        
        var imagePaths: [String] = []
        
        for imageData in imageDatas {
            let imagePath = try await uploadImage(path: storagePath, containerID: containerID, imageData: imageData)
            imagePaths.append(imagePath)
        }
        
        if let thumbnailImageData = imageDatas.first,
           let resizedImageData = await UIImage(data: thumbnailImageData)?
            .byPreparingThumbnail(ofSize: .init(width: 256, height: 256))?
            .jpegData(compressionQuality: 1) {
            let thumbnailImagePath = try await uploadImage(
                path: storagePath,
                containerID: "\(containerID)/thumbnail",
                imageData: resizedImageData
            )
            
            imagePaths.insert(thumbnailImagePath, at: 0)
        }
        
        return imagePaths
    }
    
    
    /// Image를 수정하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 저장하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담을 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imagePath: 수정하려는 Image의 Path
    ///   - imageData: 수정할 Image의 Data
    public func updateImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String,
        imageData: Data
    ) async throws {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePath.isEmpty {
            throw StorageError.invalidImagePath
        }
        
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
    ///   - imagePaths: container에 저장되어있던 ImagePath 배열
    ///   - imageDatas: 수정할 Image의 Data 배열
    public func updateImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String],
        imageDatas: [Data]
    ) async throws -> [String] {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePaths.isEmpty {
            throw StorageError.invalidImagePath
        }
        
        if imageDatas.isEmpty {
            throw StorageError.invalidImageData
        }
        
        var updatedImagePaths: [String] = imagePaths
        let storageImagePathList = try await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .listAll()
            .items
            .map { $0.name }
        let firstStorageImagePath = storageImagePathList.first ?? ""
        
        for imagePath in storageImagePathList where !imagePaths.contains(imagePath) {
            try await deleteImage(path: storagePath, containerID: containerID, imagePath: imagePath)
            
            if imagePath == firstStorageImagePath {
                try await deleteImage(path: storagePath, containerID: "\(containerID)/thumbnail", imagePath: imagePath)
            }
        }
        
        for (imagePath, imageData) in zip(imagePaths, imageDatas) where !storageImagePathList.contains(imagePath)  {
            try await uploadImage(path: storagePath, containerID: containerID, imageData: imageData)
        }
        
        if let thumbnailImageData = imageDatas.first {
            let thumbnailImagePath = try await uploadImage(
                path: storagePath,
                containerID: "\(containerID)/thumbnail",
                imageData: thumbnailImageData
            )
            
            updatedImagePaths.insert(thumbnailImagePath, at: 0)
        }
        
        return updatedImagePaths
    }
    
    
    /// Image를 FirebaseStorage에서 불러오는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 불러오려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담은 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imagePath: 저장한 Image의 Path
    public func downloadImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String
    ) async throws -> Data {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePath.isEmpty {
            throw StorageError.invalidImagePath
        }
        
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
    ///   - imagePaths: 저장한 Image들의 Path 배열
    public func downloadImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String]
    ) async throws -> [Data] {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePaths.isEmpty {
            throw StorageError.invalidImagePath
        }
        
        var imageDatas: [Data] = []
        
        for imagePath in imagePaths {
            let imageData = try await downloadImage(path: storagePath, containerID: containerID, imagePath: imagePath)
            imageDatas.append(imageData)
        }
        
        return imageDatas
    }
    
    
    /// 이미지를 삭제하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 삭제하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담은 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imagePath: 저장한 Image의 Path
    public func deleteImage(
        path storagePath: StoragePath,
        containerID: String,
        imagePath: String
    ) async throws {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePath.isEmpty {
            throw StorageError.invalidImagePath
        }
        
        guard let _ = try? await storageRef
            .child(storagePath.rawValue)
            .child(containerID)
            .child(imagePath)
            .delete()
        else {
            throw StorageError.deleteError
        }
    }
    
    
    /// 이미지 배열을 삭제하는 메서드
    ///
    /// - Parameters:
    ///   - path: Image를 삭제하려는 탭 (ex: Article, Trade, Profile)
    ///   - containerID: Image를 담은 모델의 ID (ex: ArticleID, TradeID, UserID)
    ///   - imagePaths: 저장한 Image의 Path 배열
    public func deleteImageList(
        path storagePath: StoragePath,
        containerID: String,
        imagePaths: [String]
    ) async throws {
        if containerID.isEmpty {
            throw StorageError.invalidContainerID
        }
        
        if imagePaths.isEmpty {
            throw StorageError.invalidImagePath
        }
        
        for imagePath in imagePaths {
            try await deleteImage(path: storagePath, containerID: containerID, imagePath: imagePath)
        }
    }
}
