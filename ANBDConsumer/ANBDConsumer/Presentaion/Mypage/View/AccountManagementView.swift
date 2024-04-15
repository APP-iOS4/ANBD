//
//  UserInfoDetailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct AccountManagementView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @State private var isShowingEditorView = false
    @State private var isShowingSignOutAlertView = false
    @State private var isShowingWithdrawalAlertView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                DetailInfoComponentView(title: "가입한 계정",
                                        content: "anbd@anbd.co.kr")
                .padding(.top, 30)
                
                DetailInfoComponentView(title: "닉네임",
                                        content: myPageViewModel.user.nickname)
                
                DetailInfoComponentView(title: "선호하는 거래 지역",
                                        content: myPageViewModel.user.favoriteLocation.description)
                
                VStack {
                    Rectangle()
                        .fill(Color.gray50)
                        .frame(height: 100)
                    
                    Button(action: {
                        isShowingSignOutAlertView.toggle()
                    }, label: {
                        Text("로그아웃")
                            .modifier(WarningTextModifier())
                    })
                    
                    Rectangle()
                        .fill(Color.gray50)
                        .frame(height: 40)
                    
                    Button(action: {
                        isShowingWithdrawalAlertView.toggle()
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
            
            if isShowingSignOutAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingSignOutAlertView, viewType: .signOut) {
                    // 로그아웃 메서드 넣기
                    authenticationViewModel.authState = false
                }
            }
            
            if isShowingWithdrawalAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingWithdrawalAlertView, viewType: .withdrawal) {
                    // 회원 탈퇴 메서드 넣기
                    authenticationViewModel.authState = false
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    myPageViewModel.tempUserFavoriteLocation = myPageViewModel.user.favoriteLocation
                    isShowingEditorView.toggle()
                }, label: {
                    Text("수정")
                })
            }
        }
        
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        
        .fullScreenCover(isPresented: $isShowingEditorView) {
            UserInfoEditingView()
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

fileprivate struct WarningTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(ANBDFont.SubTitle1)
            .foregroundStyle(Color.heartRed)
            .frame(maxWidth: .infinity, minHeight: 45)
    }
}

#Preview {
    NavigationStack {
        AccountManagementView()
            .environmentObject(MyPageViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
