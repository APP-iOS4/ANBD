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
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @StateObject private var coordinator = Coordinator.shared
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var writerUser: User
    
    @State private var category: ANBDCategory = .accua
    
    @State private var isSignedInUser: Bool = false
    
    @State private var isShowingReportView = false
    @State private var isShowingBlockingUserAlert = false
    @State private var refreshView = false
    
    init(writerUser: User) {
        self.writerUser = writerUser
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    userProfileImage
                        .onChange(of: myPageViewModel.tempUserProfileImage) {
                            Task {
                                try await Task.sleep(nanoseconds: 800_000_000)
                                refreshView.toggle()
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(myPageViewModel.user.nickname)")
                            .foregroundStyle(Color.gray900)
                            .font(ANBDFont.pretendardBold(24))
                            .padding(.bottom, 10)
                        
                        Text("선호 지역 : \(myPageViewModel.user.favoriteLocation.description)")
                            .foregroundStyle(Color.gray400)
                            .font(ANBDFont.Caption3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isSignedInUser {
                            HStack {
                                Text(verbatim: "\(myPageViewModel.user.email)")
                                    .foregroundStyle(Color.gray400)
                                
                                Spacer()
                            }
                            .font(ANBDFont.Caption3)
                        }
                    }
                }
                .padding()
                
                HStack(spacing: 12) {
                    activityInfoComponent(title: "아껴 쓴 개수", category: .accua)
                    
                    Divider()
                        .frame(height: 60)
                    
                    activityInfoComponent(title: "나눠 쓴 개수", category: .nanua)
                    
                    Divider()
                        .frame(height: 60)
                    
                    activityInfoComponent(title: "바꿔 쓴 개수", category: .baccua)
                    
                    Divider()
                        .frame(height: 60)
                    
                    activityInfoComponent(title: "다시 쓴 개수", category: .dasi)
                }
                
                if isSignedInUser {
                    VStack(alignment: .leading) {
                        Divider()
                        
                        Button(action: {
                            coordinator.category = .accua
                            coordinator.appendPath(.userLikedContentView)
                        }, label: {
                            listButtonView(title: "내가 좋아요한 게시글 보기")
                        })
                        
                        Divider()
                        
                        Button(action: {
                            coordinator.category = .nanua
                            coordinator.appendPath(.userLikedContentView)
                        }, label: {
                            listButtonView(title: "내가 찜한 나눔・거래 보기")
                                .padding(.bottom, -10)
                        })
                    }
                }
                
                Rectangle()
                    .fill(Color.gray50)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
            }
            
            if isShowingBlockingUserAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingBlockingUserAlert, viewType: .userBlocked) {
                    Task {
                        await myPageViewModel.blockUser(
                            userID: UserStore.shared.user.id,
                            blockingUserID: writerUser.id,
                            blockingUserNickname: writerUser.nickname
                        )
                        coordinator.pop(2)
                    }
                }
            }
        }
        .toolbarRole(.editor)
        .toolbar {
            if isSignedInUser && coordinator.selectedTab == .mypage {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        coordinator.appendPath(.settingsView)
                    }, label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                    })
                }
            } else if isSignedInUser == false && writerUser.id != "abcd1234" {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            isShowingBlockingUserAlert.toggle()
                        } label: {
                            Label("사용자 차단하기", systemImage: "person.slash")
                        }
                        
                        Button(role: .destructive) {
                            coordinator.reportType = .user
                            coordinator.reportedObjectID = writerUser.id
                            coordinator.appendPath(.reportView)
                        } label: {
                            Label("사용자 신고하기", systemImage: "exclamationmark.bubble")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 13))
                            .rotationEffect(.degrees(90))
                            .foregroundStyle(.gray900)
                    }
                }
            }
        }
        .navigationTitle("\(navigationTitle)")
        .navigationBarTitleDisplayMode(.inline)
        
        .fullScreenCover(isPresented: $isShowingReportView) {
            ReportView(reportedObjectID: writerUser.id)
        }
        
        .onAppear {
            coordinator.isFromUserPage = false
            isSignedInUser = myPageViewModel.checkSignInedUser(userID: writerUser.id)
            
            Task {
                myPageViewModel.user = await myPageViewModel.getUserInfo(userID: writerUser.id)
            }
        }
    }
    
    private var userProfileImage: some View {
        AsyncImage(url: URL(string: myPageViewModel.user.profileImage)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(width: 95, height: 95)
        .clipShape(.circle)
        .padding(.horizontal, 10)
        .overlay(
            Circle()
                .stroke(colorScheme == .dark ? Color.gray600 : Color.gray100, lineWidth: 1)
        )
        .id(refreshView)
    }
    
    private func activityInfoComponent(title: String, category: ANBDCategory) -> some View {
        Button(action: {
            coordinator.category = category
            coordinator.isSignedInUser = isSignedInUser
            coordinator.appendPath(.userActivityView)
        }, label: {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Group {
                    switch category {
                    case .accua:
                        Text("\(myPageViewModel.user.accuaCount)")
                    case .nanua:
                        Text("\(myPageViewModel.user.nanuaCount)")
                    case .baccua:
                        Text("\(myPageViewModel.user.baccuaCount)")
                    case .dasi:
                        Text("\(myPageViewModel.user.dasiCount)")
                    }
                }
                .font(ANBDFont.pretendardSemiBold(22))
            }
        })
    }
    
    private func listButtonView(title: String) -> some View {
        Text("\(title)")
            .foregroundStyle(Color.gray900)
            .font(ANBDFont.SubTitle2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
}

extension UserPageView {
    private var navigationTitle: String {
        switch isSignedInUser {
        case true: return "내 정보"
        case false: return "사용자 정보"
        }
    }
}

#Preview {
    NavigationStack {
        UserPageView(writerUser: MyPageViewModel.mockUser)
            .environmentObject(MyPageViewModel())
            .environmentObject(TradeViewModel())
    }
}
