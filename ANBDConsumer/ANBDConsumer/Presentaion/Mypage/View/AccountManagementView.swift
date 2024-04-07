//
//  UserInfoDetailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct AccountManagementView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @State private var isShowingEditorView = false
    
    var body: some View {
        VStack(spacing: 40) {
            DetailInfoComponentView(title: "가입한 계정", content: "sjybext@naver.com")
                .padding(.top, 30)
            
            DetailInfoComponentView(title: "닉네임", content: myPageViewModel.user.nickname)
            
            DetailInfoComponentView(title: "선호하는 거래 지역", content: myPageViewModel.user.favoriteLocation.rawValue)
            
            VStack {
                Rectangle()
                    .fill(Color.gray50)
                    .frame(height: 100)
                
                Button(action: {
                    // MARK: 로그아웃 Alert
                }, label: {
                    Text("로그아웃")
                        .modifier(WarningTextModifier())
                })
                
                Rectangle()
                    .fill(Color.gray50)
                    .frame(height: 40)
                
                Button(action: {
                    // MARK: 회원탈퇴 Alert
                }, label: {
                    Text("회원탈퇴")
                        .modifier(WarningTextModifier())
                })
                
                Rectangle()
                    .fill(Color.gray50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingEditorView.toggle()
                }, label: {
                    Text("수정")
                })
            }
        }
        
        .fullScreenCover(isPresented: $isShowingEditorView) {
            UserInfoEditorView()
        }
    }
    
    @ViewBuilder
    private func DetailInfoComponentView(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("\(title)")
                .font(ANBDFont.SubTitle2)
                .foregroundStyle(Color.gray400)
            
            Text("\(content)")
                .font(ANBDFont.SubTitle1)
                .foregroundStyle(Color.gray900)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 25)
    }
}

#Preview {
    NavigationStack {
        AccountManagementView()
            .environmentObject(MyPageViewModel())
    }
}

private struct WarningTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ANBDFont.SubTitle1)
            .foregroundStyle(Color.heartRed)
            .frame(maxWidth: .infinity, minHeight: 45)
    }
}
