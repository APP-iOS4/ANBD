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
    
    @State private var isNavigate = false
    @State private var isShowingDuplicatedEmailAlert = false
    @State private var isShwoingEmailValidationCheckView = false
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
                        
                        Task {
                            if await authenticationViewModel.checkDuplicatedEmail() {
                                isShowingDuplicatedEmailAlert.toggle()
                            } else {
                                nextButtonAction()
                            }
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
                                if await !authenticationViewModel.checkDuplicatedEmail() {
                                    downKeyboard()
                                    isShowingDuplicatedEmailAlert.toggle()
                                } else {
                                    isShwoingEmailValidationCheckView.toggle()
                                    downKeyboard()
                                    authenticationViewModel.isValidEmailButtonDisabled = true
                                    authenticationViewModel.validEmailRemainingTime = 60
                                    // TODO: - 이메일 검증
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
                
                BlueSquareButton(title: "다음", isDisabled: !isCompletedEmailValidation) {
                    nextButtonAction()
                }
            }
            .padding()
            
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
            SignUpPasswordView()
        }
        
        .onAppear {
            focus = .email
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
