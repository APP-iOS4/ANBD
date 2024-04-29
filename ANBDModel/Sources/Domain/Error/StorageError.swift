//
//  StorageError.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum StorageError: Int, Error {
    case invalidContainerID = 4050
    case invalidImagePath
    case invalidImageData
    case uploadError = 5037
    case downloadError
    case updateError
    case deleteError
    
    public var message: String {
        switch self {
        case .invalidContainerID: "ContainerID 누락"
        case .invalidImagePath: "ImagePath 누락"
        case .invalidImageData: "ImageData 누락"
        case .uploadError: "이미지 업로드 실패"
        case .downloadError: "이미지 다운로드 실패"
        case .updateError: "이미지 수정 실패"
        case .deleteError: "이미지 삭제 실패"
        }
    }
}
