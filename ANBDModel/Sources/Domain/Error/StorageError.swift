//
//  StorageError.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum StorageError: Error {
    case uploadError
    case downloadError
    case updateError
    case deleteError
}
