//
//  AuthenticationView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        if authenticationViewModel.authState{
            ANBDAdminAppHomeView()
        } else {
            NavigationStack {
                HStack{
                    Image("AdminLogo")
                        .resizable()
                        .scaledToFit()
                        .padding(130)
                    
                    VStack(alignment:.center) {
                        Spacer()
                        VStack(spacing: 50) {
                            TextFieldWithTitle(fieldType: .normal,
                                               title: "이메일",
                                               placeholder: "예) anbd@anbd.co.kr",
                                               inputText: $authenticationViewModel.loginEmailString)
                            .frame(height: 100)
                            .focused($focus, equals: .email)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onSubmit {
                                focus = .password
                            }
                            
                            TextFieldWithTitle(fieldType: .secure,
                                               title: "비밀번호",
                                               placeholder: "8~16자 (숫자, 영문, 특수기호 중 2개 이상)",
                                               inputText: $authenticationViewModel.loginPasswordString)
                            .frame(height: 100)
                            .focused($focus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                Task {
                                    await authenticationViewModel.signIn()
                                    authenticationViewModel.checkAuthState()
                                }
                            }
                            
                            if !authenticationViewModel.errorMessage.isEmpty {
                                Text(authenticationViewModel.errorMessage)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 8)
                                    .font(ANBDFont.Caption1)
                                    .foregroundStyle(.heartRed)
                            }
                        }
                        .padding(.bottom, 30)
                        
                        VStack(spacing: 20) {
                            BlueSquareButton(title: "로그인",
                                             isDisabled: !authenticationViewModel.isValidLogin) {
                                Task {
                                    await authenticationViewModel.signIn()
                                    authenticationViewModel.checkAuthState()
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button(action: {
                                focusPreviousField()
                            }, label: {
                                Label("Previous text field", systemImage: "chevron.up")
                            })
                            .disabled(!canFocusPreviousField())
                            
                            Button(action: {
                                focusNextField()
                            }, label: {
                                Label("Next text field", systemImage: "chevron.down")
                            })
                            .disabled(!canFocusNextField())
                            
                            Spacer()
                            
                            Button(action: {
                                downKeyboard()
                            }, label: {
                                Label("Keyboard down", systemImage: "keyboard.chevron.compact.down")
                            })
                        }
                    }
                    
                    .onAppear {
                        authenticationViewModel.clearSignUpDatas()
                        authenticationViewModel.checkAuthState()
                    }
                }
            }
        }
    }
}


extension AuthenticationView {
    enum FocusableField: Int, Hashable, CaseIterable {
        case email
        case password
    }
    
    private func focusPreviousField() {
        focus = focus.map {
            FocusableField(rawValue: $0.rawValue - 1) ?? .email
        }
    }
    
    private func focusNextField() {
        focus = focus.map {
            FocusableField(rawValue: $0.rawValue + 1) ?? .password
        }
    }
    
    private func canFocusPreviousField() -> Bool {
        guard let focus else {
            return false
        }
        
        return focus.rawValue > 0
    }
    
    private func canFocusNextField() -> Bool {
        guard let focus else {
            return false
        }
        
        return focus.rawValue < FocusableField.allCases.count - 1
    }
    
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
