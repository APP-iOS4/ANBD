//
//  SignUpUserInfoView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SignUpUserInfoView: View {
    enum FocusableField {
        case nickname
    }
    
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @FocusState private var focus: FocusableField?
    
    @State private var navigate = false
    @State private var selectedLocation: Location = .seoul
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("회원가입")
                .font(ANBDFont.Heading2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 70)
            
            TextFieldWithTitle(fieldType: .normal,
                               title: "닉네임",
                               placeholder: "2~20자의 닉네임을 입력해주세요.",
                               inputText: $authenticationViewModel.signUpNicknameString)
            .focused($focus, equals: .nickname)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.go)
            .onSubmit {
                nextButtonAction()
            }
            .padding(.bottom)
            
            if !authenticationViewModel.errorMessage.isEmpty {
                Text(authenticationViewModel.errorMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                    .font(ANBDFont.Caption1)
                    .foregroundStyle(Color.heartRed)
            }
            
            Text("선호하는 거래 지역")
                .font(ANBDFont.SubTitle3)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LocationPickerMenu(selectedItem: $selectedLocation)
                .frame(width: 170)
            
            Spacer()
            
            BlueSquareButton(title: "다음", isDisabled: !authenticationViewModel.isValidSignUpNickname) {
                nextButtonAction()
            }
        }
        .padding()
        .navigationDestination(isPresented: $navigate) {
            SignUpPasswordView()
        }
        
        .onAppear {
            focus = .nickname
        }
        
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            
            ToolbarItem(placement: .keyboard) {
                Button(action: {
                    downKeyboard()
                }, label: {
                    Label("Keyboard down", systemImage: "keyboard.chevron.compact.down")
                })
            }
        }
    }
    
    private func nextButtonAction() {
        navigate = true
    }
}

#Preview {
    SignUpUserInfoView()
        .environmentObject(AuthenticationViewModel())
}

extension SignUpUserInfoView {
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
