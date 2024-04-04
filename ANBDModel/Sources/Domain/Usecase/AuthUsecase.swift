//
//  File.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseAuth

public protocol AuthUsecase {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String,
                password: String,
                nickname: String,
                favoriteLocation: Location,
                isOlderThanFourteen: Bool,
                isAgreeService: Bool,
                isAgreeCollectInfo: Bool,
                isAgreeMarketing: Bool) async throws -> User
    func signOut() async throws
    func withdrawal(userID: String) async throws
    func checkDuplicatedEmail(email: String) async -> Bool
    func checkDuplicatedNickname(nickname: String) async -> Bool
}

@available(iOS 13, *)
public struct DefaultAuthUsecase: AuthUsecase {
    
    private let userRepository = DefaultUserRepository()
    
    public init() { }
    
    /// 로그인 API
    /// - Parameters:
    ///   - email: User의 이메일
    ///   - password: User의 비밀번호
    /// - Returns: User 로그인에 성공한 User의 정보
    public func signIn(email: String, password: String) async throws -> User {
        let signInResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let userID = signInResult.user.uid
        
        guard let userInfo = try? await userRepository.readUserInfo(userID: userID)
        else {
            throw AuthError.signInError(message: "로그인에 실패했습니다.")
        }
        
        return userInfo
    }
    
    /// 회원가입 API
    /// - Parameters:
    ///   - email: User의 이메일
    ///   - password: User의 비밀번호
    ///   - user: 회원가입할 User의 정보
    /// - Returns: User 회원가입에 성공한 User의 정보
    public func signUp(
        email: String,
        password: String,
        nickname: String,
        favoriteLocation: Location,
        isOlderThanFourteen: Bool,
        isAgreeService: Bool,
        isAgreeCollectInfo: Bool,
        isAgreeMarketing: Bool
    ) async throws -> User {
        let signUpResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userID = signUpResult.user.uid
        
        let newUser = User(
            id: userID,
            nickname: nickname,
            email: email,
            favoriteLocation: favoriteLocation,
            isOlderThanFourteen: isOlderThanFourteen,
            isAgreeService: isAgreeService,
            isAgreeCollectInfo: isAgreeCollectInfo,
            isAgreeMarketing: isAgreeMarketing
        )
        
        guard let userInfo = try? await userRepository.createUserInfo(user: newUser)
        else {
            throw AuthError.signUpError(message: "회원가입에 실패했습니다.")
        }
        
        return userInfo
    }
    
    /// 로그아웃 API
    ///
    /// FirebaseAuth에서 로그아웃을 요청한다. 로컬에 저장된 User정보는 별도로 처리해줄 것
    public func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    /// 회원탈퇴 API
    /// @param userID 탈퇴할 User의 ID
    ///
    /// UserDB 상에서 User document를 삭제한다.
    /// 로컬에 저장된 User정보는 별도로 처리해줄 것
    public func withdrawal(userID: String) async throws {
        try await signOut()
        try await userRepository.deleteUserInfo(userID: userID)
    }
    
    /// 이메일 중복체크 API
    /// @param email 중복여부를 확인할 email
    /// @returns 중복된 이메일일 경우 `true`를, 중복되지 않았을 경우 `false`를 반환한다.
    public func checkDuplicatedEmail(email: String) async -> Bool {
        do {
            try await userRepository.checkUser(email: email)
            return false
        } catch {
            return true
        }
    }
    
    /// 닉네임 중복체크 API
    /// @param nickname 중복여부를 확인할 nickname
    /// @returns 중복된 닉네임일 경우 `true`를, 중복되지 않았을 경우 `false`를 반환한다.
    public func checkDuplicatedNickname(nickname: String) async -> Bool {
        do {
            try await userRepository.checkUser(nickname: nickname)
            return false
        } catch {
            return true
        }
    }
    
}
