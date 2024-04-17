//
//  SignUpPasswordView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpPasswordView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @FocusState private var focus: FocusableField?
    
    @State private var navigate = false
    
    var body: some View {
        VStack {
            Text("회원가입")
                .font(ANBDFont.Heading2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 70)
            
            TextFieldWithTitle(fieldType: .secure,
                               title: "비밀번호",
                               placeholder: "8~16자 (숫자, 영문, 특수기호 중 2개 이상)",
                               inputText: $authenticationViewModel.signUpPasswordString)
            .focused($focus, equals: .password)
            .submitLabel(.next)
            .onSubmit {
                focus = .passwordCheck
            }
            .padding(.bottom)
            
            TextFieldWithTitle(fieldType: .secure,
                               title: "비밀번호 확인",
                               placeholder: "비밀번호를 한 번 더 입력해주세요.",
                               inputText: $authenticationViewModel.signUpPasswordCheckString)
            .focused($focus, equals: .passwordCheck)
            .submitLabel(.go)
            .onSubmit {
                guard authenticationViewModel.isValidSignUpPassword else { return }
                nextButtonAction()
            }
            
            if !authenticationViewModel.errorMessage.isEmpty {
                Text(authenticationViewModel.errorMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .font(ANBDFont.Caption1)
                    .foregroundStyle(Color.heartRed)
            }
            
            Spacer()
            
            BlueSquareButton(title: "다음", isDisabled: !authenticationViewModel.isValidSignUpPassword) {
                nextButtonAction()
            }
        }
        .padding()
        
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
        
        .navigationDestination(isPresented: $navigate) {
            SignUpUserInfoView()
        }
        
        .onAppear {
            focus = .password
        }
    }
    
    private func nextButtonAction() {
        navigate = true
    }
}

#Preview {
    SignUpPasswordView()
        .environmentObject(AuthenticationViewModel())
}

extension SignUpPasswordView {
    enum FocusableField: Int, Hashable, CaseIterable {
        case password
        case passwordCheck
    }
    
    private func focusPreviousField() {
        focus = focus.map {
            FocusableField(rawValue: $0.rawValue - 1) ?? .password
        }
    }
    
    private func focusNextField() {
        focus = focus.map {
            FocusableField(rawValue: $0.rawValue + 1) ?? .passwordCheck
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
