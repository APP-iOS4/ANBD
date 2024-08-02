//
//  SignUpUserInfoView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SignUpUserInfoView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @FocusState private var focus: FocusableField?
    
    @State private var isNavigate = false
    @State private var isShowingMenuList: Bool = false
    @State private var isShwoingDuplicatedNicknameAlert = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("회원가입")
                    .font(ANBDFont.Heading2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.bottom, 70)
                
                textFieldWithTitle
                    .onChange(of: authenticationViewModel.signUpNicknameString) {
                        authenticationViewModel.signUpNicknameString = authenticationViewModel.checkNicknameLength(authenticationViewModel.signUpNicknameString)
                    }
                
                HStack {
                    Spacer()
                    
                    Text("\(authenticationViewModel.signUpNicknameString.count)/18")
                        .padding(.horizontal, 5)
                        .font(ANBDFont.body2)
                        .foregroundStyle(.gray400)
                }
                .padding(.top, -15)
                
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
                
                LocationPickerMenu(isShowingMenuList: $isShowingMenuList, selectedItem: $authenticationViewModel.signUpUserFavoriteLoaction)
                
                Spacer()
                
                BlueSquareButton(title: "다음", isDisabled: !authenticationViewModel.isValidSignUpNickname) {
                    Task {
                        if await authenticationViewModel.checkDuplicatedNickname() {
                            downKeyboard()
                            isShwoingDuplicatedNicknameAlert.toggle()
                        } else {
                            nextButtonAction()
                        }
                    }
                }
            }
            .padding()
            
            if isShwoingDuplicatedNicknameAlert {
                CustomAlertView(isShowingCustomAlert: $isShwoingDuplicatedNicknameAlert, viewType: .duplicatedNickname) {
                    focus = .nickname
                }
            }
        }
        .toolbarRole(.editor)
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
        
        .navigationDestination(isPresented: $isNavigate) {
            SignUpPolicyAgreeView()
        }
        
        .onAppear {
            focus = .nickname
        }
    }
    
    private var textFieldWithTitle: some View {
        TextFieldWithTitle(fieldType: .normal,
                           title: "닉네임",
                           placeholder: "2~20자의 닉네임을 입력해주세요.",
                           inputText: $authenticationViewModel.signUpNicknameString)
        .focused($focus, equals: .nickname)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .submitLabel(.go)
        .onSubmit {
            guard authenticationViewModel.isValidSignUpNickname else { return }
            
            Task {
                if await authenticationViewModel.checkDuplicatedNickname() {
                    isShwoingDuplicatedNicknameAlert.toggle()
                } else {
                    nextButtonAction()
                }
            }
        }
        .padding(.bottom)
    }
    
    private func nextButtonAction() {
        isNavigate = true
    }
}

#Preview {
    SignUpUserInfoView()
        .environmentObject(AuthenticationViewModel())
}

extension SignUpUserInfoView {
    enum FocusableField {
        case nickname
    }
    
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
