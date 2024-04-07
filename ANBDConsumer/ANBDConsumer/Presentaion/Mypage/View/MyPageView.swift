//
//  MypageView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var mypageViewModel = MyPageViewModel()
    
    var body: some View {
        VStack {
            UserInfoView()
            
            UserActivityInformationView()
            
            OtherSettingsView()
            
            Spacer()
        }
        .environmentObject(mypageViewModel)
    }
}

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

struct UserActivityInformationView: View {
    var body: some View {
        HStack(spacing: 12) {
            ActivityInformationComponent(title: "아껴 쓴 개수", count: 5)
            Divider()
                .frame(height: 60)
            
            ActivityInformationComponent(title: "나눠 쓴 개수", count: 8)
            Divider()
                .frame(height: 60)
            
            ActivityInformationComponent(title: "바꿔 쓴 개수", count: 13)
            Divider()
                .frame(height: 60)
            
            ActivityInformationComponent(title: "다시 쓴 개수", count: 19)
        }
    }
    
    @ViewBuilder
    func ActivityInformationComponent(title: String, count: Int) -> some View {
        Button(action: {
            
        }, label: {
            VStack(alignment: .center) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
            }
        })
    }
}

struct OtherSettingsView: View {
    @State var isShowingPolicyView: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            
            Button(action: {
                // 각 리스트로 이동할 뷰
            }, label: {
                Text("내가 찜한 나눔 ・ 거래 보기")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.SubTitle2)
                    .padding()
            })
            
            Divider()
            
            Button(action: {
                isShowingPolicyView.toggle()
            }, label: {
                Text("약관 및 정책")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.SubTitle2)
                    .padding()
            })
            
            Divider()
        }
        .navigationDestination(isPresented: $isShowingPolicyView) {
            Text("약관 및 정책")
        }
    }
}

#Preview {
    NavigationStack {
        MyPageView()
    }
}
