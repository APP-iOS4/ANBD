//
//  File.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum AuthError: Error {
    case signInError(message: String)
    case signUpError(message: String)
    case duplicatedEmail(message: String)
    case duplicatedNickname(message: String)
}
