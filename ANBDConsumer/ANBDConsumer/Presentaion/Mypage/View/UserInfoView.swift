//
//  UserInfoView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var mypageViewModel: MyPageViewModel
    
    var body: some View {
        HStack {
            Image(uiImage: mypageViewModel.userProfileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .clipShape(.circle)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("\(mypageViewModel.userNickname) 님")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.Heading3)
                
                Text("선호 지역 : \(mypageViewModel.userPreferredTradingArea)")
                    .foregroundStyle(Color.gray400)
                    .font(ANBDFont.Caption3)
                
                HStack {
                    Text(verbatim: "sjybext@naver.com")
                        .foregroundStyle(Color.gray400)
                    
                    Spacer()
                    
                    Button(action: {
                        // 계정관리 뷰
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
    }
}

#Preview {
    UserInfoView()
        .environmentObject(MyPageViewModel())
}
