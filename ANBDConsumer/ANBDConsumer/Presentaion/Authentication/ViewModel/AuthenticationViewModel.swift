//
//  AuthenticationViewModel.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import Foundation
import Combine
import ANBDModel

final class AuthenticationViewModel: ObservableObject {
    
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
    
    // Nickname Field
    @Published var signUpNicknameString: String = ""
    @Published private(set) var signUpNicknameStringDebounced: String = ""
    
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
    
    @Published var showingTermsView: Bool = false
    
    @Published private(set) var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $loginEmailString
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.loginEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $loginPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
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
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard let self = self else { return }
                self.signUpEmailStringDebounced = email
            }
            .store(in: &cancellables)
        
        $signUpPasswordString
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpPasswordCheckString
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard let self = self else { return }
                self.signUpPasswordCheckStringDebounced = password
            }
            .store(in: &cancellables)
        
        $signUpNicknameString
            .removeDuplicates()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
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
            errorMessage = "비밀번호가 다릅니다."
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
        let regex = #"^[0-9a-z가-힣][0-9a-z가-힣._]{0,18}[0-9a-z가-힣]$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
}
