//
//  SignUpEmailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpEmailView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focus: FocusableField?
    
    @State private var isNavigate = false
    @State private var isShowingDuplicatedEmailAlert = false
    @State private var isShowingSignUpCancelAlert = false
    @State private var isShwoingEmailValidationCheckView = false
    
    @State private var isWaitingForEmailValidation = false
    @State private var isCompletedEmailValidation = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                Text("회원가입")
                    .font(ANBDFont.Heading2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.bottom, 70)
                
                HStack {
                    if isWaitingForEmailValidation == false {
                        TextFieldWithTitle(fieldType: .normal,
                                           title: "이메일 주소",
                                           placeholder: "예) anbd@anbd.co.kr",
                                           inputText: $authenticationViewModel.signUpEmailString)
                        .focused($focus, equals: .email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.go)
                    } else {
                        VStack(alignment: .leading) {
                            Text("이메일 주소")
                                .font(ANBDFont.SubTitle3)
                                .foregroundStyle(Color.gray900)
                            
                            Text("\(authenticationViewModel.signUpEmailString)")
                                .font(ANBDFont.body2)
                                .padding(.horizontal, 4)
                                .padding(.top, 1)
                            
                            Divider()
                                .foregroundStyle(.gray200)
                        }
                    }
                    
                    if isCompletedEmailValidation {
                        Text("인증완료")
                            .padding(.all, 9)
                            .font(ANBDFont.pretendardSemiBold(14))
                            .foregroundStyle(Color(uiColor: .systemGreen))
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(uiColor: .systemGreen), lineWidth: 1)
                            }
                            .offset(y: 9)
                    } else {
                        Button(action: {
                            Task {
                                if await authenticationViewModel.checkDuplicatedEmail() {
                                    downKeyboard()
                                    isShowingDuplicatedEmailAlert.toggle()
                                } else {
                                    downKeyboard()
                                    isShwoingEmailValidationCheckView.toggle()
                                    isWaitingForEmailValidation.toggle()
                                    
                                    authenticationViewModel.isValidEmailButtonDisabled = true
                                    authenticationViewModel.validEmailRemainingTime = 30
                                    
                                    await authenticationViewModel.verifyEmail()
                                }
                            }
                        }, label: {
                            Text("인증하기")
                                .padding(.all, 9)
                                .font(ANBDFont.body2)
                                .foregroundStyle(Color.white)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(authenticationViewModel.isValidSignUpEmail && !authenticationViewModel.isValidEmailButtonDisabled ? Color.accent : Color.gray300)
                                }
                        })
                        .offset(y: 9)
                        .disabled(!authenticationViewModel.isValidSignUpEmail || authenticationViewModel.isValidEmailButtonDisabled)
                    }
                }
                
                HStack {
                    if !authenticationViewModel.errorMessage.isEmpty {
                        Text(authenticationViewModel.errorMessage)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color.heartRed)
                    }
                    
                    Spacer()
                    
                    if authenticationViewModel.isValidEmailButtonDisabled == true && isCompletedEmailValidation == false {
                        Text("\(authenticationViewModel.validEmailRemainingTime)초 후에 다시 시도하세요.")
                            .foregroundStyle(Color.gray)
                    }
                }
                .font(ANBDFont.Caption1)
                .padding(.top, 8)
                
                if !isWaitingForEmailValidation {
                    HStack {
                        Text("이미 계정이 있으신가요?")
                            .foregroundStyle(.gray)
                        
                        Button("로그인") {
                            if isCompletedEmailValidation {
                                isShowingSignUpCancelAlert.toggle()
                            } else {
                                dismiss()
                            }
                        }
                        .foregroundStyle(.accent)
                    }
                    .font(ANBDFont.body2)
                    .padding(.top, 22)
                } else {
                    Button {
                        isCompletedEmailValidation = false
                        isWaitingForEmailValidation.toggle()
                        authenticationViewModel.signUpEmailString = ""
                        focus = .email
                        
                        Task {
                            await authenticationViewModel.withdrawal() { }
                        }
                    } label: {
                        Text("다른 이메일로 가입하기")
                    }
                    .font(ANBDFont.body2)
                    .padding(.top, 22)
                }
                
                Spacer()
                
                BlueSquareButton(title: "다음",
                                 isDisabled: !isCompletedEmailValidation || authenticationViewModel.signUpEmailString.isEmpty) {
                    isWaitingForEmailValidation = false
                    nextButtonAction()
                }
            }
            .padding()
            
            if isShowingSignUpCancelAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingSignUpCancelAlert, viewType: .signUpCancel) {
                    Task {
                        await authenticationViewModel.withdrawal() { }
                        dismiss()
                    }
                }
            }
            
            if isShowingDuplicatedEmailAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingDuplicatedEmailAlert, viewType: .duplicatedEmail) {
                    focus = .email
                }
            }
            
            if isShwoingEmailValidationCheckView {
                CustomAlertView(isShowingCustomAlert: $isShwoingEmailValidationCheckView,
                                viewType: .validEmail) {
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    if isCompletedEmailValidation {
                        isShowingSignUpCancelAlert.toggle()
                    } else {
                        dismiss()
                    }
                }, label: {
                    Label("뒤로 가기", systemImage: "chevron.backward")
                })
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button(action: {
                    downKeyboard()
                }, label: {
                    Label("Keyboard down", systemImage: "keyboard.chevron.compact.down")
                })
            }
        }
        
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $isNavigate) {
            SignUpPasswordView()
        }
        
        .onAppear {
            focus = .email
            Task {
                await authenticationViewModel.withdrawal() { }
            }
        }
        
        .onReceive(timer) { _ in
            if authenticationViewModel.isValidEmailButtonDisabled {
                if authenticationViewModel.validEmailRemainingTime > 0 {
                    authenticationViewModel.validEmailRemainingTime -= 1
                } else {
                    authenticationViewModel.isValidEmailButtonDisabled = false
                }
            }
            isCompletedEmailValidation = authenticationViewModel.checkEmailVerified()
        }
    }
    
    private func nextButtonAction() {
        isNavigate = true
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView()
    }
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
