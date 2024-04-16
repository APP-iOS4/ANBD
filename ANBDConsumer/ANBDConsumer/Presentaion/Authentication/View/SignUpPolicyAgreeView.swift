//
//  SignUpAgreeView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpPolicyAgreeView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("회원가입")
                .font(ANBDFont.Heading2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)
                .padding(.bottom, 70)
            
            Text("ANBD\n서비스 이용 약관")
                .font(ANBDFont.Heading3)
                .foregroundStyle(Color.gray900)
            
            Button(action: {
                authenticationViewModel.toggleAllAgree()
            }, label: {
                HStack(spacing: 12) {
                    Image(systemName: authenticationViewModel.isAllAgree() ? "checkmark.circle.fill" :"checkmark.circle")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.accent)
                    
                    Text("모두 동의 (선택 정보 포함)")
                        .font(ANBDFont.SubTitle2)
                }
            })
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            PolicyDetailView(
                isAgree: $authenticationViewModel.isOlderThanFourteen,
                explainString: "만 14세 이상입니다. (필수)"
            )
            
            PolicyDetailView(
                isAgree: $authenticationViewModel.isAgreeService,
                explainString: "서비스 이용약관에 동의 (필수)"
            ) {
                authenticationViewModel.showTermsView(type: .agreeService)
            }
            
            PolicyDetailView(
                isAgree: $authenticationViewModel.isAgreeCollectInfo,
                explainString: "개인정보 수집 및 이용에 동의 (필수)"
            ) {
                authenticationViewModel.showTermsView(type: .agreeCollectionInfo)
            }
            
            PolicyDetailView(
                isAgree: $authenticationViewModel.isAgreeMarketing,
                explainString: "광고 및 마케팅 수신에 동의 (선택)"
            ) {
                authenticationViewModel.showTermsView(type: .agreeMarketing)
            }
            
            Spacer()
            
            BlueSquareButton(title: "회원가입 완료", isDisabled: !authenticationViewModel.isEssentialAgree()) {
                authenticationViewModel.isValidSignUp = true
            }
        }
        .padding()
        
        .sheet(isPresented: $authenticationViewModel.showingTermsView) {
            TermsView()
        }
        
        .navigationDestination(isPresented: $authenticationViewModel.isValidSignUp) {
            SignUpCompleteView()
        }
    }
}

#Preview {
    SignUpPolicyAgreeView()
        .environmentObject(AuthenticationViewModel())
}
