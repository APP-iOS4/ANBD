//
//  AuthenticationViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import Combine
import ANBDModel

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let authUsecase: AuthUsecase = DefaultAuthUsecase()
    private let userUsecase: UserUsecase = DefaultUserUsecase()
    
    @Published var authState: Bool = false
    
    @Published var validEmailRemainingTime = 30
    @Published var isValidEmailButtonDisabled = false
    
    // MARK: Login Field
    @Published var loginEmailString: String = ""
    @Published private(set) var loginEmailStringDebounced: String = ""
    
    @Published var loginPasswordString: String = ""
    @Published private(set) var loginPasswordStringDebounced: String = ""
    
    @Published private(set) var isValidLogin: Bool = false
    
    // MARK: Sign Up Field
    // Email Field
    @Published var signUpEmailString: String = ""
    @Published private(set) var signUpEmailStringDebounced: String = ""
    
    // Password Field
    @Published var signUpPasswordString: String = ""
    @Published private(set) var signUpPasswordStringDebounced: String = ""
    @Published var signUpPasswordCheckString: String = ""
    @Published private(set) var signUpPasswordCheckStringDebounced: String = ""
    
    // UserInfo Field
    @Published var signUpNicknameString: String = ""
    @Published private(set) var signUpNicknameStringDebounced: String = ""
    @Published var signUpUserFavoriteLoaction: Location = .seoul
    
    // Validation
    @Published private(set) var isValidSignUpEmail: Bool = false
    @Published private(set) var isValidSignUpPassword: Bool = false
    @Published private(set) var isValidSignUpNickname: Bool = false
    @Published var isValidSignUp: Bool = false
    
    // Agree Field
    @Published var isOlderThanFourteen: Bool = false
    @Published var isAgreeService: Bool = false
    @Published var isAgreeCollectInfo: Bool = false
    @Published var isAgreeMarketing: Bool = false
    
    @Published var agreeType: AgreeType = .agreeCollectionInfo
    
    @Published var isShowingTermsView: Bool = false
    @Published var isShowingService: Bool = false
    @Published var isShowingCollectInfo: Bool = false
    @Published var isShowingMarketing: Bool = false
    
    @Published private(set) var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $loginEmailString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.loginEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $loginPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.loginPasswordStringDebounced = password
            }
            .store(in: &cancellables)
        
        $isValidLogin
            .combineLatest($loginEmailStringDebounced, $loginPasswordStringDebounced)
            .map { [weak self] _, email, password in
                guard let self = self else { return false }
                return self.validateLogin(email: email, password: password)
            }
            .assign(to: &$isValidLogin)
        
        $signUpEmailString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.signUpEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $signUpPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpPasswordCheckString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordCheckStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpNicknameString
            .removeDuplicates()
            .debounce(for: .seconds(0.65), scheduler: DispatchQueue.main)
            .sink { [weak self] nickname in
                guard let self = self else { return }
                self.signUpNicknameStringDebounced = nickname
            }
            .store(in: &cancellables)
        
        $isValidSignUpEmail
            .combineLatest($signUpEmailStringDebounced)
            .map { [weak self] _, email in
                guard let self = self else { return false }
                return self.validateSignUpEmail(email: email)
            }
            .assign(to: &$isValidSignUpEmail)
        
        $isValidSignUpPassword
            .combineLatest($signUpPasswordStringDebounced, $signUpPasswordCheckStringDebounced)
            .map { [weak self] _, password, passwordCheck in
                guard let self = self else { return false }
                return self.validateSignUpPassword(password: password, passwordCheck: passwordCheck)
            }
            .assign(to: &$isValidSignUpPassword)
        
        $isValidSignUpNickname
            .combineLatest($signUpNicknameStringDebounced)
            .map { [weak self] _, nickname in
                guard let self = self else { return false }
                return self.validateSignUpNickname(nickname: nickname)
            }
            .assign(to: &$isValidSignUpNickname)
    }
}

// MARK: Validate Method
extension AuthenticationViewModel {
    func validateLogin(email: String, password: String) -> Bool {
        if (!email.isEmpty && !email.isValidateEmail()) && (!password.isEmpty && !password.isValidatePassword()) {
            errorMessage = "잘못된 이메일 또는 비밀번호 형식입니다."
        } else if !email.isEmpty && !email.isValidateEmail() {
            errorMessage = "잘못된 이메일 형식입니다."
        } else if !password.isEmpty && !password.isValidatePassword() {
            errorMessage = "잘못된 비밀번호 형식입니다."
        } else {
            errorMessage = ""
        }
        
        return (!email.isEmpty && email.isValidateEmail()) && (!password.isEmpty && password.isValidatePassword())
    }
    
    func validateSignUpEmail(email: String) -> Bool {
        if !email.isEmpty && !email.isValidateEmail() {
            errorMessage = "잘못된 이메일 형식입니다."
        } else {
            errorMessage = ""
        }
        
        return !email.isEmpty && email.isValidateEmail()
    }
    
    func validateSignUpPassword(password: String, passwordCheck: String) -> Bool {
        if !password.isEmpty && !password.isValidatePassword() {
            errorMessage = "잘못된 비밀번호 형식입니다."
        } else if !password.isEmpty && !passwordCheck.isEmpty && password != passwordCheck {
            errorMessage = "비밀번호가 일치하지 않습니다."
        } else {
            errorMessage = ""
        }
        
        return (!password.isEmpty && password.isValidatePassword()) && (!passwordCheck.isEmpty && password == passwordCheck)
    }
    
    func validateSignUpNickname(nickname: String) -> Bool {
        if !nickname.isEmpty && !nickname.isValidateNickname() {
            errorMessage = "잘못된 닉네임 형식입니다."
        } else {
            errorMessage = ""
        }
        
        return !nickname.isEmpty && nickname.isValidateNickname()
    }
}

// MARK: Sign Up Method
extension AuthenticationViewModel {
    func checkAuthState() {
        if let _ = UserDefaultsClient.shared.userID, UserStore.shared.user.userLevel != .banned {
            authState = true
        } else {
            authState = false
            if UserStore.shared.user.userLevel == .banned {
                errorMessage = "해당 계정은 접근 권한이 없습니다."
            }
        }
    }
    
    func toggleAllAgree() {
        if !isAllAgree() {
            isOlderThanFourteen = true
            isAgreeService = true
            isAgreeCollectInfo = true
            isAgreeMarketing = true
        } else {
            isOlderThanFourteen.toggle()
            isAgreeService.toggle()
            isAgreeCollectInfo.toggle()
            isAgreeMarketing.toggle()
        }
    }
    
    func isAllAgree() -> Bool {
        return isOlderThanFourteen && isAgreeService && isAgreeCollectInfo && isAgreeMarketing
    }
    
    func isEssentialAgree() -> Bool {
        return isOlderThanFourteen && isAgreeService && isAgreeCollectInfo
    }
    
    func showTermsView(type: AgreeType) {
        switch type {
        case .agreeService:
            agreeType = .agreeService
        case .agreeCollectionInfo:
            agreeType = .agreeCollectionInfo
        case .agreeMarketing:
            agreeType = .agreeMarketing
        default:
            return
        }
        
        isShowingTermsView.toggle()
    }
    
    func updateUserToken() async {
        do {
            try await userUsecase.updateUserFCMToken(userID: UserStore.shared.user.id, fcmToken: UserStore.shared.deviceToken)
        } catch {
            #if DEBUG
            print("updateUserToken:\(error)")
            #endif
        }
    }
    
    func signIn() async -> Bool {
        do {
            let signedInUser = try await authUsecase.signIn(email: loginEmailString,
                                                            password: loginPasswordString)
            
            UserDefaultsClient.shared.userID = signedInUser.id
            UserStore.shared.user = signedInUser
            
            return true
        } catch {
            #if DEBUG
            print("Error sign in: \(error.localizedDescription)")
            #endif
            return false
        }
    }
    
    func signOut(_ completion: @escaping () -> Void) async {
        do {
            //중복로그인된 아이디가 로그아웃 되었을때 가장 최근 로그인된 디바이스의 토큰을 초기화 하지 않기 위하여
            if (UserStore.shared.deviceToken == UserStore.shared.user.fcmToken) || (UserStore.shared.user.userLevel == .banned) {
                try await userUsecase.updateUserFCMToken(userID: UserStore.shared.user.id, fcmToken: "")
            }
            try await authUsecase.signOut()
            completion()
        } catch {
            #if DEBUG
            print("Error sign out: \(error.localizedDescription)")
            #endif
            guard let error = error as? AuthError else {
                ToastManager.shared.toast = Toast(style: .error, message: "알 수 없는 오류가 발생하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func signUp() async {
        do {
            let signedUpUser = try await authUsecase.signUp(email: signUpEmailString,
                                                            password: signUpPasswordString,
                                                            nickname: signUpNicknameString,
                                                            favoriteLocation: signUpUserFavoriteLoaction,
                                                            fcmToken: "",
                                                            isOlderThanFourteen: isOlderThanFourteen,
                                                            isAgreeService: isAgreeService,
                                                            isAgreeCollectInfo: isAgreeCollectInfo,
                                                            isAgreeMarketing: isAgreeMarketing)
            
            UserDefaultsClient.shared.userID = signedUpUser.id
            UserStore.shared.user = signedUpUser
        } catch {
            #if DEBUG
            print("Error sign up: \(error.localizedDescription)")
            #endif
            guard let error = error as? AuthError else {
                ToastManager.shared.toast = Toast(style: .error, message: "알 수 없는 오류가 발생하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func checkDuplicatedEmail() async -> Bool {
        let isDuplicate = await authUsecase.checkDuplicatedEmail(email: signUpEmailString)
        
        return isDuplicate
    }
    
    func verifyEmail() async {
        do {
            try await authUsecase.verifyEmail(email: signUpEmailStringDebounced)
        } catch {
            #if DEBUG
            print("Error verify email: \(error.localizedDescription)")
            #endif
            guard let error = error as? AuthError else {
                ToastManager.shared.toast = Toast(style: .error, message: "알 수 없는 오류가 발생하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func checkEmailVerified() -> Bool {
        return authUsecase.checkEmailVerified()
    }
    
    func checkDuplicatedNickname() async -> Bool {
        let isDuplicate = await authUsecase.checkDuplicatedNickname(nickname: signUpNicknameString)
        
        return isDuplicate
    }
    
    func checkNicknameLength(_ nickname: String) -> String {
        if nickname.count > 18 {
            return String(nickname.prefix(18))
        } else {
            return nickname
        }
    }
    
    func withdrawal(_ completion: @escaping () -> Void) async {
        do {
            try await authUsecase.withdrawal()
            
            completion()
        } catch {
            #if DEBUG
            print("Error withdrawal: \(error.localizedDescription)")
            #endif
            guard let error = error as? AuthError else {
                ToastManager.shared.toast = Toast(style: .error, message: "알 수 없는 오류가 발생하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
    
    func clearSignUpDatas() {
        loginEmailString = ""
        loginPasswordString = ""
        
        signUpEmailString = ""
        signUpPasswordString = ""
        signUpPasswordCheckString = ""
        signUpNicknameString = ""
        signUpUserFavoriteLoaction = .seoul
        
        isOlderThanFourteen = false
        isAgreeService = false
        isAgreeCollectInfo = false
        isAgreeMarketing = false
        
        isValidSignUp = false
    }
}

enum AgreeType {
    case olderThanFourTeen
    case agreeService
    case agreeCollectionInfo
    case agreeMarketing
    
    var url: String {
        switch self {
        case .olderThanFourTeen:
            return ""
        case .agreeService:
            return "https://oval-second-abc.notion.site/ANBD-0cde8fed32014e19830309431bfcdebb"
        case .agreeCollectionInfo:
            return "https://oval-second-abc.notion.site/ANBD-4b59058a70ba46ef9753fe40502f94e3"
        case .agreeMarketing:
            return "https://oval-second-abc.notion.site/ANBD-f265775da8fe4fe3957048f4c2028f5a"
        }
    }
}
