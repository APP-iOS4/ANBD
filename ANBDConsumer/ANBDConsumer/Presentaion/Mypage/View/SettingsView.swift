//
//  SettingsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/28/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    @State private var isShowingPolicyView = false
    
    private var spacingValue: CGFloat = 25
    
    var body: some View {
        VStack(spacing: spacingValue) {
            SettingSectionView(title: "사용자 설정", spacingValue: spacingValue) {
                Button(action: {
                    coordinator.mypagePath.append(Page.accountManagementView)
                }, label: {
                    Text("계정 / 정보 관리")
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
                
                HStack {
                    Text("문의 메일")
                    
                    Spacer()
                    
                    Text("anbd@test.com")
                        .foregroundStyle(Color.gray500)
                }
            }
            
            Rectangle()
                .fill(Color.gray50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        
        
        .fullScreenCover(isPresented: $isShowingPolicyView) {
            SafariWebView(url: URL(string: "https://maru-study-note.tistory.com/")!)
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
            .environmentObject(Coordinator())
    }
}
