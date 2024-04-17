//
//  DBError.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum DBError: Int, Error {
    case unknownError = 5000
    
    case setUserDocumentError = 5001
    case getUserDocumentError
    case updateUserDocumentError
    case deleteUserDocumentError
    
    case setArticleDocumentError = 5005
    case getArticleDocumentError
    case updateArticleDocumentError
    case deleteArticleDocumentError
    
    case setCommentDocumentError = 5009
    case getCommentDocumentError
    case updateCommentDocumentError
    case deleteCommentDocumentError
    
    case setTradeDocumentError = 5013
    case getTradeDocumentError
    case updateTradeDocumentError
    case deleteTradeDocumentError
    
    case setBannerDocumentError = 5021
    case getBannerDocumentError
    case updateBannerDocumentError
    case deleteBannerDocumentError
    
    public var message: String {
        switch self {
        case .unknownError: "알 수 없는 에러"
        case .setUserDocumentError: "User document 추가 실패"
        case .getUserDocumentError: "User document 읽기 실패"
        case .updateUserDocumentError: "User document 수정 실패"
        case .deleteUserDocumentError: "User document 삭제 실패"
        case .setArticleDocumentError: "Article document 추가 실패"
        case .getArticleDocumentError: "Article document 읽기 실패"
        case .updateArticleDocumentError: "Article document 수정 실패"
        case .deleteArticleDocumentError: "Article document 삭제 실패"
        case .setCommentDocumentError: "Comment document 추가 실패"
        case .getCommentDocumentError: "Comment document 읽기 실패"
        case .updateCommentDocumentError: "Comment document 수정 실패"
        case .deleteCommentDocumentError: "Comment document 삭제 실패"
        case .setTradeDocumentError: "Trade document 추가 실패"
        case .getTradeDocumentError: "Trade document 읽기 실패"
        case .updateTradeDocumentError: "Trade document 수정 실패"
        case .deleteTradeDocumentError: "Trade document 삭제 실패"
        case .setBannerDocumentError: "Banner document 추가 실패"
        case .getBannerDocumentError: "Banner document 읽기 실패"
        case .updateBannerDocumentError: "Banner document 수정 실패"
        case .deleteBannerDocumentError: "Banner document 삭제 실패"
        }
    }
}
