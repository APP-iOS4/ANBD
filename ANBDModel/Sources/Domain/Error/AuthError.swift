//
//  AuthError.swift
//
//
//  Created by 유지호 on 4/4/24.
//

import Foundation

public enum AuthError: Int, Error {
    case duplicatedEmail = 4000
    case invalidEmailField
    case invalidEmailRegularExpression
    case invalidPasswordField = 4003
    case invalidPasswordRegularExpression
    case duplicatedNickname = 4005
    case invalidNicknameField
    case invalidNicknameRegularExpression
    case invalidFavoriteLocationField = 4008
    
    public var message: String {
        switch self {
        case .duplicatedEmail: "이메일이 중복됨"
        case .invalidEmailField: "이메일 필드 누락"
        case .invalidEmailRegularExpression: "이메일 정규식 틀림"
        case .invalidPasswordField: "비밀번호 필드 누락"
        case .invalidPasswordRegularExpression: "비밀번호 정규식 틀림"
        case .duplicatedNickname: "닉네임 중복됨"
        case .invalidNicknameField: "닉네임 필드 누락"
        case .invalidNicknameRegularExpression: "닉네임 정규식 틀림"
        case .invalidFavoriteLocationField: "선호 거래지역 필드 누락"
        }
    }
}
