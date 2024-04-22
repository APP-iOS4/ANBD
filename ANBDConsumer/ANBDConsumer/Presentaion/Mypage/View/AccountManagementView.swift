//
//  UserInfoDetailView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct AccountManagementView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @State private var isShowingEditorView = false
    @State private var isShowingSignOutAlertView = false
    @State private var isShowingWithdrawalAlertView = false
    
    @State private var refreshView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                detailInfoComponentView(title: "가입한 계정",
                                        content: UserStore.shared.user.email)
                .padding(.top, 30)
                
                detailInfoComponentView(title: "닉네임",
                                        content: UserStore.shared.user.nickname)
                
                detailInfoComponentView(title: "선호하는 거래 지역",
                                        content: UserStore.shared.user.favoriteLocation.description)
                
                VStack {
                    Rectangle()
                        .fill(Color.gray50)
                        .frame(height: 100)
                    
                    Button(action: {
                        isShowingSignOutAlertView.toggle()
                    }, label: {
                        Text("로그아웃")
                            .modifier(warningTextModifier())
                    })
                    
                    Rectangle()
                        .fill(Color.gray50)
                        .frame(height: 40)
                    
                    Button(action: {
                        isShowingWithdrawalAlertView.toggle()
                    }, label: {
                        Text("회원탈퇴")
                            .modifier(warningTextModifier())
                    })
                    
                    Rectangle()
                        .fill(Color.gray50)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                }
            }
            
            if isShowingSignOutAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingSignOutAlertView, viewType: .signOut) {
                    Task {
                        try await authenticationViewModel.signOut {
                            UserDefaultsClient.shared.removeUserID()
                            UserStore.shared.user = MyPageViewModel.mockUser
                            authenticationViewModel.checkAuthState()
                            
                            myPageViewModel.myPageNaviPath.removeLast()
                        }
                    }
                }
            }
            
            if isShowingWithdrawalAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingWithdrawalAlertView, viewType: .withdrawal) {
                    Task {
                        try await authenticationViewModel.withdrawal {
                            UserDefaultsClient.shared.removeUserID()
                            UserStore.shared.user = MyPageViewModel.mockUser
                            authenticationViewModel.checkAuthState()
                            
                            myPageViewModel.myPageNaviPath.removeLast()
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    myPageViewModel.tempUserFavoriteLocation = UserStore.shared.user.favoriteLocation
                    isShowingEditorView.toggle()
                }, label: {
                    Text("수정")
                })
            }
        }
        
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        
        .fullScreenCover(isPresented: $isShowingEditorView, onDismiss: {
            refreshView.toggle()
        }) {
            UserInfoEditingView()
        }
    }
    
    private func detailInfoComponentView(title: String, content: String) -> some View {
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
        .id(refreshView)
    }
}

fileprivate struct warningTextModifier: ViewModifier {
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
