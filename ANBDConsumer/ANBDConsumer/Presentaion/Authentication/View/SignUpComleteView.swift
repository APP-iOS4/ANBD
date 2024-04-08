//
//  SignUpComleteView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct SignUpComleteView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @State private var showTitleAnimation: CGFloat = .zero
    @State private var showExplainAnimation: CGFloat = .zero
    
    var body: some View {
        VStack {
            Text("회원가입이\n완료되었습니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 54)
                .padding(.bottom, 60)
                .font(ANBDFont.Heading2)
                .opacity(showTitleAnimation)
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundStyle(Color.accent)
                .frame(width: 200, height: 200)
                .padding(.bottom, 20)
                .opacity(showTitleAnimation)
            
            Text("ANBD와 함께\n환경절약을 실천해요!")
                .multilineTextAlignment(.center)
                .font(ANBDFont.Heading3)
                .opacity(showExplainAnimation)
            
            Spacer()
            
            BlueSquareButton(title: "시작하기") {
                
            }
            .opacity(showExplainAnimation)
        }
        .padding(.horizontal, 20)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.easeOut(duration: 1)) {
                showTitleAnimation = 1
            } completion: {
                withAnimation(.easeOut(duration: 2)) {
                    showExplainAnimation = 1
                }
            }
        }
    }
}

#Preview {
    SignUpComleteView()
        .environmentObject(AuthenticationViewModel())
}
