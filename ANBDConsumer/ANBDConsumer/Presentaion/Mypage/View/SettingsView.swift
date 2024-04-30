//
//  SettingsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/28/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @StateObject private var coordinator = Coordinator.shared
    
    @State private var isShowingEditorView = false
    @State private var isShowingPolicyView = false
    @State private var isShowingSignOutAlertView = false
    @State private var isShowingWithdrawalAlertView = false
    @State private var isShowingOpenSourceLicense = false
    
    private let spacingValue: CGFloat = 30
    
    var body: some View {
        ZStack {
            VStack(spacing: spacingValue) {
                SettingSectionView(title: "사용자 설정", spacingValue: spacingValue) {
                    Button(action: {
                        myPageViewModel.tempUserFavoriteLocation = UserStore.shared.user.favoriteLocation
                        isShowingEditorView.toggle()
                    }, label: {
                        Text("유저 정보 수정")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                }
                .padding(.top, 15)
                
                Divider()
                
                SettingSectionView(title: "기타", spacingValue: spacingValue) {
                    Button(action: {
                        isShowingPolicyView.toggle()
                    }, label: {
                        Text("약관 및 정책")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    
                    HStack {
                        Text("앱 버전")
                        
                        Spacer()
                        
                        Text("\(myPageViewModel.getCurrentAppVersion())")
                            .foregroundStyle(Color.gray500)
                    }
                    
                    Button(action: {
                        isShowingOpenSourceLicense.toggle()
                    }, label: {
                        Text("오픈소스 라이선스")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    
                    HStack {
                        Text("문의 메일")
                        
                        Spacer()
                        
                        Text("jrjr4426@gmail.com")
                            .foregroundStyle(Color.gray500)
                    }
                    
                    Button(action: {
                        isShowingSignOutAlertView.toggle()
                    }, label: {
                        Text("로그아웃")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    
                    Button(action: {
                        isShowingWithdrawalAlertView.toggle()
                    }, label: {
                        Text("회원 탈퇴")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                }
                
                Rectangle()
                    .fill(Color.gray50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            
            if isShowingSignOutAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingSignOutAlertView, viewType: .signOut) {
                    Task {
                        await authenticationViewModel.signOut {
                            UserDefaultsClient.shared.removeUserID()
                            UserStore.shared.user = MyPageViewModel.mockUser
                            authenticationViewModel.checkAuthState()
                            
                            coordinator.pop()
                            coordinator.selectedTab = .home
                        }
                    }
                }
            }
            
            if isShowingWithdrawalAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingWithdrawalAlertView, viewType: .withdrawal) {
                    Task {
                        await authenticationViewModel.withdrawal {
                            UserDefaultsClient.shared.removeUserID()
                            UserStore.shared.user = MyPageViewModel.mockUser
                            authenticationViewModel.checkAuthState()
                            
                            coordinator.pop()
                            coordinator.selectedTab = .home
                        }
                    }
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        
        .fullScreenCover(isPresented: $isShowingEditorView, onDismiss: {
            myPageViewModel.tempUserProfileImage = nil
            myPageViewModel.tempUserNickname = ""
            myPageViewModel.tempUserFavoriteLocation = .seoul
            
            Task {
                myPageViewModel.user = await myPageViewModel.getUserInfo(userID: UserStore.shared.user.id)
            }
        }) {
            UserInfoEditingView()
        }
        
        .fullScreenCover(isPresented: $isShowingPolicyView) {
            SafariWebView(url: URL(string: "https://oval-second-abc.notion.site/ANBD-036716b1ef784b019ab0df8147bd4e65")!)
                .ignoresSafeArea(edges: .bottom)
        }
        
        .fullScreenCover(isPresented: $isShowingOpenSourceLicense) {
            SafariWebView(url: URL(string: "https://oval-second-abc.notion.site/97ddaf4813f7481a84c36ff4f3c3faef")!)
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

fileprivate struct SettingSectionView<Content: View>: View {
    private let title: String
    private let spacingValue: CGFloat
    
    private let content: Content
    
    init(title: String, spacingValue: CGFloat, @ViewBuilder content: () -> Content) {
        self.title = title
        self.spacingValue = spacingValue
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacingValue) {
            Text("\(title)")
                .font(ANBDFont.pretendardBold(14))
            
            content
                .font(ANBDFont.pretendardRegular(17))
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(MyPageViewModel())
            .environmentObject(AuthenticationViewModel())
    }
}
