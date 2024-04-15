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
    
    private let userUseCase: UserUsecase = DefaultUserUsecase()
    
    @State private var isShowingAccountManagementView = false
    @State private var isShowingPolicyView = false
    @State private var isShowingReportDialog = false
    @State private var isShowingHeartTrades = false
    @State private var isShowingLikedArticles = false
    
    @State private var category: ANBDCategory = .accua
    
    // 임시 분기처리를 위한 프로퍼티
    var isSignedInUser: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // UserInfo
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
            
            // User Activities
            Group {
                HStack(spacing: 12) {
                    ActivityInfoComponent(title: "아껴 쓴 개수", count: 5, category: .accua)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "나눠 쓴 개수", count: 8, category: .nanua)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "바꿔 쓴 개수", count: 13, category: .baccua)
                    Divider()
                        .frame(height: 60)
                    
                    ActivityInfoComponent(title: "다시 쓴 개수", count: 19, category: .dasi)
                }
            }
            
            if isSignedInUser {
                // Another Functions
                Group {
                    VStack(alignment: .leading) {
                        Divider()
                        
                        Button(action: {
                            isShowingHeartTrades.toggle()
                        }, label: {
                            Text("내가 찜한 나눔・거래 보기")
                                .foregroundStyle(Color.gray900)
                                .font(ANBDFont.SubTitle2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        })
                        
                        Divider()
                        
                        Button(action: {
                            isShowingLikedArticles.toggle()
                        }, label: {
                            Text("내가 좋아요한 게시글 보기")
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
                    .fullScreenCover(isPresented: $isShowingPolicyView) {
                        SafariWebView(url: URL(string: "https://maru-study-note.tistory.com/")!)
                            .ignoresSafeArea(edges: .bottom)
                    }
                    
                    .navigationDestination(isPresented: $isShowingHeartTrades) {
                        UserLikedContentsView(category: .nanua)
                            .toolbarRole(.editor)
                            .toolbar(.hidden, for: .tabBar)
                    }
                    .navigationDestination(isPresented: $isShowingLikedArticles) {
                        UserLikedContentsView(category: .accua)
                            .toolbarRole(.editor)
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
                            .font(.system(size: 13))
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
    private func ActivityInfoComponent(title: String, count: Int, category: ANBDCategory) -> some View {
        NavigationLink {
            if isSignedInUser {
                UserActivityListView(category: category,
                                     user: myPageViewModel.user)
                .toolbarRole(.editor)
            } else {
                UserActivityListView(category: category,
                                     user: myPageViewModel.user)
            }
        } label: {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
                    .font(ANBDFont.pretendardSemiBold(22))
            }
        }
        
    }
}

#Preview {
    NavigationStack {
        UserPageView(isSignedInUser: true)
            .environmentObject(MyPageViewModel())
    }
}
