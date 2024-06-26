//
//  AuthenticationViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import Combine
import ANBDModel
import UIKit

enum AgreeType {
    case olderThanFourTeen
    case agreeService
    case agreeCollectionInfo
    case agreeMarketing
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    private let authUsecase: AuthUsecase = DefaultAuthUsecase()
    
    @Published var authState: Bool = false
    
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
    
    @Published private(set) var termsString: String = ""
    @Published var showingTermsView: Bool = false
    
    @Published private(set) var errorMessage: String = ""
    
    @Published var user = User(id: "",
                               nickname: "",
                               profileImage: "",
                               email: "",
                               favoriteLocation: .seoul,
                               userLevel: .consumer, fcmToken: "",
                               isOlderThanFourteen: false,
                               isAgreeService: false,
                               isAgreeCollectInfo: false,
                               isAgreeMarketing: false,
                               likeArticles: [],
                               likeTrades: [])
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $loginEmailString
            .removeDuplicates()
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.loginEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $loginPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
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
            .debounce(for: .seconds(0.05), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.signUpEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $signUpPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpPasswordCheckString
            .removeDuplicates()
            .debounce(for: .seconds(0.05), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordCheckStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpNicknameString
            .removeDuplicates()
            .debounce(for: .seconds(0.05), scheduler: DispatchQueue.main)
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
    func submitSignUp() {
        authState = true
    }
    
    func checkAuthState() {
        if let _ = UserDefaultsClient.shared.userID, UserStore.shared.user.userLevel == .admin {
                authState = true
            } else {
                authState = false
                errorMessage = "접근 권한이 없습니다."
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
            termsString = "서비스 이용 약관에 동의하십니까?"
        case .agreeCollectionInfo:
            termsString = "개인정보 수집 및 이용에 동의하십니까?"
        case .agreeMarketing:
            termsString = "광고 및 마케팅 수신에 동의하십니까?"
        default:
            termsString = ""
            return
        }
        
        showingTermsView.toggle()
    }
    
    func signIn() async -> Bool {
            do {
                let signedInUser = try await authUsecase.signIn(email: loginEmailString,
                                                                password: loginPasswordString)
                
                UserDefaultsClient.shared.userID = signedInUser.id
                UserStore.shared.user = signedInUser
                
                return true
            } catch {
                print("Error sign in: \(error.localizedDescription)")
                
                return false
            }
        }
    
    func signOut(completion: @escaping () -> Void) async throws {
        do {
            try await authUsecase.signOut()
            
            completion()
            authState = false
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func checkDuplicatedEmail() async -> Bool {
        let isDuplicate = await authUsecase.checkDuplicatedEmail(email: signUpEmailString)
        
        return isDuplicate
    }
    
    func checkDuplicatedNickname() async -> Bool {
        let isDuplicate = await authUsecase.checkDuplicatedNickname(nickname: signUpNicknameString)
        
        return isDuplicate
    }
    
    /*
     func signUpWithGoogle() async {
     do {
     guard let user = Auth.auth().currentUser
     else {
     throw AuthError.tokenError(message: "잘못된 액세스 토큰입니다.")
     }
     
     let serviceUser = User(
     userNickname: signUpNicknameString,
     email: user.email ?? "",
     accessToken: user.uid,
     isOlderThanFourteen: isOlderThanFourteen,
     isAgreeService: isAgreeService,
     isAgreeCollectInfo: isAgreeCollectInfo,
     isAgreeMarketing: isAgreeMarketing
     )
     
     try await userStore.saveUserInfo(userInfo: serviceUser)
     isValidSignUp = true
     UserDefaultsManager.shared.userInfo = serviceUser
     } catch {
     errorMessage = error.localizedDescription
     }
     }
     */
    
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

extension String {
    func isValidateEmail() -> Bool {
        let emailRegEx = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#
        let last = self.contains("com") || self.contains("net") || self.contains("co.kr")
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: self) && last
    }
    
    func isValidatePassword() -> Bool {
        let regex = #"^(?!([A-Za-z]+|[~!@#$%^&*()_+=]+|[0-9]+)$)[A-Za-z\d~!@#$%^&*()_+=]{8,16}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func isValidateNickname() -> Bool {
        let regex = #"(?i)^[0-9a-z가-힣][0-9a-z가-힣._]{0,18}[0-9a-z가-힣]$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
