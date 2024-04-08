//
//  UserInfoView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @State private var isShowingAccountManagementView = false
    
    var body: some View {
        HStack {
            Image(uiImage: myPageViewModel.userProfileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .clipShape(.circle)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("\(myPageViewModel.user.nickname) 님")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.pretendardBold(24))
                
                Text("선호 지역 : \(myPageViewModel.user.favoriteLocation.description)")
                    .foregroundStyle(Color.gray400)
                    .font(ANBDFont.Caption3)
                
                HStack {
                    Text(verbatim: "sjybext@naver.com")
                        .foregroundStyle(Color.gray400)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingAccountManagementView.toggle()
                    }, label: {
                        Text("계정관리")
                    })
                }
                .font(ANBDFont.Caption3)
            }
        }
        .padding()
        .navigationTitle("마이페이지")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isShowingAccountManagementView) {
            AccountManagementView()
                // 아마 최상위에서 주입하면 지워도 되지 않을까?
                .environmentObject(myPageViewModel)
                .toolbarRole(.editor)
        }
    }
}

#Preview {
    UserInfoView()
        .environmentObject(MyPageViewModel())
}
