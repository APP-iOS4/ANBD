//
//  DBError.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum DBError: Int, Error {
    case unknownError = 5000
    
    case setDocumentError = 5001
    case getDocumentError
    case updateDocumentError
    case deleteDocumentError
    
    case setUserDocumentError = 5005
    case getUserDocumentError
    case updateUserDocumentError
    case deleteUserDocumentError
    
    case setTradeDocumentError = 5017
    case getTradeDocumentError
    case updateTradeDocumentError
    case deleteTradeDocumentError
    
    case setChannelDocumentError = 5021
    case getChannelDocumentError
    case updateChannelDocumentError
    case deleteChannelDocumentError
    
    case setMessageDocumentError = 5025
    case getMessageDocumentError
    case updateMessageDocumentError
    case deleteMessageDocumentError
    
    case setReportDocumentError = 5033
    case getReportDocumentError
    case deleteReportDocumentError
    
    public var message: String {
        switch self {
        case .unknownError: "알 수 없는 에러"
            
        case .setDocumentError: "Document 추가 실패"
        case .getDocumentError: "Document 읽기 실패"
        case .updateDocumentError: "Document 수정 실패"
        case .deleteDocumentError: "Document 삭제 실패"
            
        case .setUserDocumentError: "User document 추가 실패"
        case .getUserDocumentError: "User document 읽기 실패"
        case .updateUserDocumentError: "User document 수정 실패"
        case .deleteUserDocumentError: "User document 삭제 실패"
            
        case .setTradeDocumentError: "Trade document 추가 실패"
        case .getTradeDocumentError: "Trade document 읽기 실패"
        case .updateTradeDocumentError: "Trade document 수정 실패"
        case .deleteTradeDocumentError: "Trade document 삭제 실패"
            
        case .setChannelDocumentError: "Channel document 추가 실패"
        case .getChannelDocumentError: "Channel document 읽기 실패"
        case .updateChannelDocumentError: "Channel document 수정 실패"
        case .deleteChannelDocumentError: "Channel document 삭제 실패"
            
        case .setMessageDocumentError: "Message document 추가 실패"
        case .getMessageDocumentError: "Message document 읽기 실패"
        case .updateMessageDocumentError: "Message document 수정 실패"
        case .deleteMessageDocumentError: "Message document 삭제 실패"
            
        case .setReportDocumentError: "Report document 추가 실패"
        case .getReportDocumentError: "Report document 읽기 실패"
        case .deleteReportDocumentError: "Report document 삭제 실패"
        }
    }
}
