//
//  BlockingUserListView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 5/20/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct BlockingUserListView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    var body: some View {
        Group {
            if myPageViewModel.blockedUserList.isEmpty {
                ListEmptyView(description: "차단한 사용자가 없습니다.")
            } else {
                ScrollView(.vertical) {
                    Divider()
                        .padding(.bottom, 5)
                    
                    LazyVStack {
                        ForEach(myPageViewModel.blockedUserList) { blockedUser in
                            BlockingUserCell(blockedUser: blockedUser)
                        }
                    }
                }
                .refreshable {
                    await myPageViewModel.getBlockList(userID: UserStore.shared.user.id)
                }
            }
        }
        .navigationTitle("차단 사용자 관리")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        
        .onAppear {
            Task {
                await myPageViewModel.getBlockList(userID: UserStore.shared.user.id)
            }
        }
    }
}

fileprivate struct BlockingUserCell: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    var blockedUser: User
    
    @State private var isBlocked = true
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                KFImage(URL(string: blockedUser.profileImage))
                    .placeholder { _ in
                        ProgressView()
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 0.2))
                    .frame(width: 45, height: 45)
                
                Text("\(blockedUser.nickname)")
                    .font(ANBDFont.pretendardRegular(17))
                    .foregroundStyle(Color.gray900)
                    .padding(.leading, 5)
                
                Spacer()
                
                if isBlocked {
                    Button {
                        Task {
                            await myPageViewModel.unblockUser(
                                userID: UserStore.shared.user.id,
                                unblockingUserID: blockedUser.id,
                                blockingUserNickname: blockedUser.nickname
                            )
                            isBlocked.toggle()
                        }
                    } label: {
                        Text("차단 해제하기")
                            .font(ANBDFont.pretendardRegular(17))
                    }
                } else {
                    Button {
                        Task {
                            await myPageViewModel.blockUser(
                                userID: UserStore.shared.user.id,
                                blockingUserID: blockedUser.id,
                                blockingUserNickname: blockedUser.nickname
                            )
                            isBlocked.toggle()
                        }
                    } label: {
                        Text("차단하기")
                            .font(ANBDFont.pretendardRegular(17))
                    }
                }
            }
            .padding(.horizontal)
        }
        
        Divider()
            .padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack {
        BlockingUserListView()
    }
    .environmentObject(MyPageViewModel())
}
