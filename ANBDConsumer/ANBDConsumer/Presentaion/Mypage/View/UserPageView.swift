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
        
    @State private var isShowingPolicyView = false
    @State private var isShowingReportDialog = false
    
    @State private var category: ANBDCategory = .accua
    
    // 임시 분기처리를 위한 프로퍼티
    var isSignedInUser: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // UserInfo
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
                                myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.accountManagement)
                            }, label: {
                                Text("계정관리")
                            })
                        }
                        .font(ANBDFont.Caption3)
                    }
                }
            }
            .padding()
            
            // User Activities
            HStack(spacing: 12) {
                activityInfoComponent(title: "아껴 쓴 개수", count: 5, category: .accua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "나눠 쓴 개수", count: 8, category: .nanua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "바꿔 쓴 개수", count: 13, category: .baccua)
                
                Divider()
                    .frame(height: 60)
                
                activityInfoComponent(title: "다시 쓴 개수", count: 19, category: .dasi)
            }
            
            if isSignedInUser {
                // Another Functions
                VStack(alignment: .leading) {
                    Divider()
                    
                    Button(action: {
                        myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.userHeartedTradeList)
                    }, label: {
                        listButtonView(title: "내가 찜한 나눔・거래 보기")
                    })
                    
                    Divider()
                    
                    Button(action: {
                        myPageViewModel.myPageNaviPath.append(MyPageViewModel.MyPageNaviPaths.userLikedArticleList)
                    }, label: {
                        listButtonView(title: "내가 좋아요한 게시글 보기")
                    })
                    
                    Divider()
                    
                    Button(action: {
                        isShowingPolicyView.toggle()
                    }, label: {
                        listButtonView(title: "약관 및 정책")
                    })
                    
                    Divider()
                }
                .fullScreenCover(isPresented: $isShowingPolicyView) {
                    SafariWebView(url: URL(string: "https://maru-study-note.tistory.com/")!)
                        .ignoresSafeArea(edges: .bottom)
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
                            .font(.system(size: 13))
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray900)
                    })
                }
            }
        }
        
        .navigationTitle("마이페이지")
        .navigationBarTitleDisplayMode(.inline)
        
        .confirmationDialog("유저 신고하기", isPresented: $isShowingReportDialog) {
            Button("신고하기", role: .destructive) {
                // 유저 신고하기 메서드
                print("유저 신고하기")
            }
        }
    }
    
    @ViewBuilder
    private func activityInfoComponent(title: String, count: Int, category: ANBDCategory) -> some View {
        NavigationLink(value: category) {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
                    .font(ANBDFont.pretendardSemiBold(22))
            }
        }
    }
    
    @ViewBuilder
    private func listButtonView(title: String) -> some View {
        Text("\(title)")
            .foregroundStyle(Color.gray900)
            .font(ANBDFont.SubTitle2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}

#Preview {
    NavigationStack {
        UserPageView(isSignedInUser: true)
            .environmentObject(MyPageViewModel())
    }
}
