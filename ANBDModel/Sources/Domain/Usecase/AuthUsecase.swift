//
//  File.swift
//  
//
//  Created by 유지호 on 4/4/24.
//

import Foundation
import FirebaseAuth

@available(iOS 15, *)
public protocol AuthUsecase {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String,
                password: String,
                nickname: String,
                favoriteLocation: Location,
                fcmToken: String,
                isOlderThanFourteen: Bool,
                isAgreeService: Bool,
                isAgreeCollectInfo: Bool,
                isAgreeMarketing: Bool) async throws -> User
    func signOut() async throws
    func withdrawal() async throws
    func verifyEmail(email: String) async throws
    func checkEmailVerified() -> Bool
    func checkDuplicatedEmail(email: String) async -> Bool
    func checkDuplicatedNickname(nickname: String) async -> Bool
}

@available(iOS 15, *)
public struct DefaultAuthUsecase: AuthUsecase {
    
    private let userRepository: UserRepository = DefaultUserRepository()
    private let articleRepository: ArticleRepository = ArticleRepositoryImpl()
    private let commentRepository: CommentRepository = CommentRepositoryImpl()
    private let tradeRepository: TradeRepository = TradeRepositoryImpl()
    
    public init() { }
    
    /// 로그인 API
    /// - Parameters:
    ///   - email: User의 이메일
    ///   - password: User의 비밀번호
    /// - Returns: User 로그인에 성공한 User의 정보
    public func signIn(email: String, password: String) async throws -> User {
        if email.isEmpty {
            throw AuthError.invalidEmailField
        } else if !email.isValidateEmail() {
            throw AuthError.invalidEmailRegularExpression
        }
        
        if password.isEmpty {
            throw AuthError.invalidPasswordField
        } else if !password.isValidatePassword() {
            throw AuthError.invalidPasswordRegularExpression
        }
        
        let signInResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let userID = signInResult.user.uid
        let userInfo = try await userRepository.readUserInfo(userID: userID)
        
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
        fcmToken: String,
        isOlderThanFourteen: Bool,
        isAgreeService: Bool,
        isAgreeCollectInfo: Bool,
        isAgreeMarketing: Bool
    ) async throws -> User {
        if email.isEmpty {
            throw AuthError.invalidEmailField
        } else if !email.isValidateEmail() {
            throw AuthError.invalidEmailRegularExpression
        }
        
        if password.isEmpty {
            throw AuthError.invalidPasswordField
        } else if !password.isValidatePassword() {
            throw AuthError.invalidPasswordRegularExpression
        }
        
        if nickname.isEmpty {
            throw AuthError.invalidNicknameField
        } else if !nickname.isValidateNickname() {
            throw AuthError.invalidNicknameRegularExpression
        }
        
        let signUpResult = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )
        
        let userID = signUpResult.user.uid
        
        let newUser = User(
            id: userID,
            nickname: nickname,
            email: email,
            favoriteLocation: favoriteLocation,
            fcmToken: fcmToken,
            isOlderThanFourteen: isOlderThanFourteen,
            isAgreeService: isAgreeService,
            isAgreeCollectInfo: isAgreeCollectInfo,
            isAgreeMarketing: isAgreeMarketing
        )
        
        let userInfo = try await userRepository.createUserInfo(user: newUser)
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
    public func withdrawal() async throws {
        guard let user = Auth.auth().currentUser else {
            print("로그인 되어있지 않음")
            throw UserError.invalidUserID
        }
        
        let articleList = try await articleRepository.readAllArticleList(writerID: user.uid)
        
        for article in articleList {
            try await articleRepository.updateArticle(articleID: article.id, nickname: "탈퇴한 사용자")
        }
        
        let commentList = try await commentRepository.readAllCommentList(writerID: user.uid)
        
        for comment in commentList {
            var updatedComment = comment
            updatedComment.writerNickname = "탈퇴한 사용자"
            
            try await commentRepository.updateComment(comment: updatedComment)
        }
        
        let tradeList = try await tradeRepository.readAllTradeList(writerID: user.uid)
        
        for trade in tradeList {
            try await tradeRepository.deleteTrade(trade: trade)
        }
        
        try await userRepository.deleteUserInfo(userID: user.uid)
        
        do {
            try await user.delete()
        } catch AuthErrorCode.requiresRecentLogin {
            print("재인증 필요")
//            let credential = AuthCredential(email: <#T##String#>, password: <#T##String#>)
//            try await user.reauthenticate(with: <#T##AuthCredential#>)
        }
    }
    
    public func verifyEmail(email: String) async throws {
        if email.isEmpty { throw AuthError.invalidEmailField }
        
        let tempResult = try await Auth.auth().createUser(
            withEmail: email,
            password: UUID().uuidString
        )
        
        let tempUser = tempResult.user
        
        try await tempUser.sendEmailVerification()
    }
    
    public func checkEmailVerified() -> Bool {
        guard let tempUser = Auth.auth().currentUser else {
            print("invalid temp user")
            return false
        }
        
        tempUser.reload()
        return tempUser.isEmailVerified
    }
    
    /// 이메일 중복체크 API
    /// @param email 중복여부를 확인할 email
    /// @returns 중복된 이메일일 경우 `true`를, 중복되지 않았을 경우 `false`를 반환한다.
    public func checkDuplicatedEmail(email: String) async -> Bool {
        do {
            try await userRepository.checkUser(email: email)
            return false
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
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
            #if DEBUG
            print(error.localizedDescription)
            #endif
            return true
        }
    }
    
}
