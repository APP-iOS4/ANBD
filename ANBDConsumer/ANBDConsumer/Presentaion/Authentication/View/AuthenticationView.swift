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
    
    @State private var isShowingSignInFailAlert = false
    
    var body: some View {
        if authenticationViewModel.authState {
            ANBDTabView()
        } else {
            NavigationStack {
                ZStack {
                    VStack {
                        VStack(spacing: 15) {
                            Text("ANBD")
                                .font(ANBDFont.Heading1)
                            
                            Text("아껴쓰고 나눠쓰고 바꿔쓰고 다시쓰고.")
                                .font(ANBDFont.body1)
                        }
                        .padding(.vertical, 80)
                        
                        VStack(spacing: 30) {
                            TextFieldWithTitle(fieldType: .normal,
                                               title: "이메일",
                                               placeholder: "예) anbd@anbd.co.kr",
                                               inputText: $authenticationViewModel.loginEmailString)
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
                            .focused($focus, equals: .password)
                            .submitLabel(.go)
                            .onSubmit {
                                Task {
                                    try await authenticationViewModel.signIn()
                                    authenticationViewModel.checkAuthState()
                                }
                            }
                            
                            if !authenticationViewModel.errorMessage.isEmpty {
                                Text(authenticationViewModel.errorMessage)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, -12)
                                    .font(ANBDFont.Caption1)
                                    .foregroundStyle(.heartRed)
                            }
                        }
                        .padding(.bottom, 30)
                        
                        VStack(spacing: 20) {
                            BlueSquareButton(title: "로그인",
                                             isDisabled: !authenticationViewModel.isValidLogin) {
                                Task {
                                    try await authenticationViewModel.signIn()
                                    authenticationViewModel.checkAuthState()
                                }
                            }
                            
                            Button(action: {
                                // 구글 로그인
#if DEBUG
                                print("구글 로그인 - 프로토타입")
#endif
                            }, label: {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray200)
                                    .overlay {
                                        HStack {
                                            Image("Google")
                                                .padding(.leading, 14)
                                            
                                            Spacer()
                                            
                                            Text("Google로 시작하기")
                                                .font(ANBDFont.body1)
                                                .foregroundStyle(Color.gray900)
                                                .padding(.trailing, 30)
                                            
                                            Spacer()
                                        }
                                        .contentShape(RoundedRectangle(cornerRadius: 14))
                                    }
                            })
                            .frame(height: 56)
                            
                            HStack {
                                Text("계정이 없으신가요?")
                                    .foregroundStyle(Color.gray400)
                                
                                NavigationLink("회원가입") {
                                    SignUpEmailView()
                                        .environmentObject(authenticationViewModel)
                                }
                                .foregroundStyle(Color.accent)
                            }
                            .font(ANBDFont.body2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if isShowingSignInFailAlert {
                        CustomAlertView(isShowingCustomAlert: $isShowingSignInFailAlert,
                                        viewType: .signInFail) {
                            focus = .email
                        }
                    }
                }
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

#Preview {
    NavigationStack {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel())
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
