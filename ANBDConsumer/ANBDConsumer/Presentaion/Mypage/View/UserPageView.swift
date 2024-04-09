//
//  MypageView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct UserPageView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @State private var isShowingAccountManagementView = false
    @State private var isShowingPolicyView = false
    @State private var isShowingReportDialog = false
    
    // 임시 분기처리를 위한 프로퍼티
    var isSignedInUser: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                HStack {
                    Image(uiImage: isSignedInUser ? myPageViewModel.userProfileImage : UIImage(named: "DefaultUserProfileImage")!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                        .clipShape(.circle)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(isSignedInUser ? "\(myPageViewModel.user.nickname) 님" : "불량마루")
                            .foregroundStyle(Color.gray900)
                            .font(ANBDFont.pretendardBold(24))
                        
                        Text("선호 지역 : \(myPageViewModel.user.favoriteLocation.description)")
                            .foregroundStyle(Color.gray400)
                            .font(ANBDFont.Caption3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isSignedInUser {
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
                }
                .padding()
                .navigationTitle("마이페이지")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $isShowingAccountManagementView) {
                    AccountManagementView()
                        .toolbarRole(.editor)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            
            Group {
                HStack(spacing: 12) {
                    ActivityInfoComponent(title: "아껴 쓴 개수", count: 5)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "나눠 쓴 개수", count: 8)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "바꿔 쓴 개수", count: 13)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "다시 쓴 개수", count: 19)
                }
            }
            
            if isSignedInUser {
                Group {
                    VStack(alignment: .leading) {
                        Divider()
                        
                        Button(action: {
                            // 각 리스트로 이동할 뷰
                        }, label: {
                            Text("내가 찜한 나눔 ・ 거래 보기")
                                .foregroundStyle(Color.gray900)
                                .font(ANBDFont.SubTitle2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        })
                        
                        Divider()
                        
                        Button(action: {
                            isShowingPolicyView.toggle()
                        }, label: {
                            Text("약관 및 정책")
                                .foregroundStyle(Color.gray900)
                                .font(ANBDFont.SubTitle2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        })
                        
                        Divider()
                    }
                    .navigationDestination(isPresented: $isShowingPolicyView) {
                        Text("약관 및 정책")
                            .toolbar(.hidden, for: .tabBar)
                    }
                }
            }
            
            if isSignedInUser {
                Spacer()
            } else {
                Rectangle()
                    .fill(Color.gray50)
                    .ignoresSafeArea()
            }
        }
        .toolbar {
            if !isSignedInUser {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingReportDialog.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15)
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray900)
                    })
                }
            }
        }
        
        .confirmationDialog("유저 신고하기", isPresented: $isShowingReportDialog) {
            Button("신고하기", role: .destructive) {
                // 유저 신고하기 메서드
                print("유저 신고하기")
            }
        }
    }
    
    @ViewBuilder
    private func ActivityInfoComponent(title: String, count: Int) -> some View {
        Button(action: {
            
        }, label: {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
                    .font(ANBDFont.pretendardSemiBold(22))
            }
        })
    }
}

#Preview {
    NavigationStack {
        UserPageView(isSignedInUser: true)
            .environmentObject(MyPageViewModel())
    }
}
