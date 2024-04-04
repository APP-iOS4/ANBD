//
//  File.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum DBError: Error {
    case setDocumentError(message: String)
    case getDocumentError(message: String)
    case updateDocumentError(message: String)
    case deleteDocumentError(message: String)
}
