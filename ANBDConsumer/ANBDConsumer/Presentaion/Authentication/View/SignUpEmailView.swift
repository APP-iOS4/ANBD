//
//  SignUpEmailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpEmailView: View {
    @Environment(\.dismiss) private var dismiss
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
            
            TextFieldWithTitle(fieldType: .normal,
                               title: "이메일 주소",
                               placeholder: "예) anbd@anbd.co.kr",
                               inputText: $authenticationViewModel.signUpEmailString)
            .focused($focus, equals: .email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.go)
            .onSubmit {
                guard authenticationViewModel.isValidSignUpEmail else { return }
                nextButtonAction()
            }
            
            if !authenticationViewModel.errorMessage.isEmpty {
                Text(authenticationViewModel.errorMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
                    .font(ANBDFont.Caption1)
                    .foregroundStyle(Color.heartRed)
            }
            
            HStack {
                Text("이미 계정이 있으신가요?")
                    .foregroundStyle(.gray)
                
                Button("로그인") {
                    dismiss()
                }
                .foregroundStyle(.accent)
            }
            .font(ANBDFont.body2)
            .padding(.top, 22)
            
            Spacer()
            
            BlueSquareButton(title: "다음", isDisabled: !authenticationViewModel.isValidSignUpEmail) {
                nextButtonAction()
            }
        }
        .padding()
        
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button(action: {
                    downKeyboard()
                }, label: {
                    Label("Keyboard down", systemImage: "keyboard.chevron.compact.down")
                })
            }
        }
        
        .navigationDestination(isPresented: $navigate) {
            SignUpPasswordView()
        }
        
        .onAppear {
            focus = .email
        }
    }
    
    private func nextButtonAction() {
        navigate = true
    }
}

#Preview {
    SignUpEmailView()
        .environmentObject(AuthenticationViewModel())
}

extension SignUpEmailView {
    enum FocusableField {
        case email
    }
    
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
