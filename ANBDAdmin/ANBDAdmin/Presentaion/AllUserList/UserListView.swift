//
//  UserListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel
import Kingfisher

struct UserListView: View {
    @StateObject private var userListViewModel = UserListViewModel()
    @State private var searchUserText = "" // 검색 텍스트 추적하는 변수
    @State private var showOnlySearchedUser:Bool = false
    let userLevel: UserLevel
    
    var body: some View {
        VStack {
            TextField("유저의 ID값으로 검색...", text: $searchUserText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onSubmit {
                    showOnlySearchedUser = true
                    if !searchUserText.isEmpty {
                        Task {
                            userListViewModel.userList = []
                            await userListViewModel.searchUser(userID:searchUserText)
                        }
                    }
                }
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("닉네임")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("이메일")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("프로필 사진")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView {
                LazyVStack{
                    ForEach(userListViewModel.userList.filter({
                        ($0.userLevel == userLevel)
                    }), id: \.id) { user in
                        NavigationLink(destination: UserListDetailView(user: user, initialUserLevel: userLevel)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(user.nickname)")
                                        .font(.title3)
                                        .lineLimit(2)
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(user.email)")
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    if let imageUrl = URL(string: user.profileImage) {
                                        KFImage(imageUrl)
                                            .placeholder {
                                                // Placeholder while downloading.
                                                ProgressView()
                                            }
                                            .resizable()
                                            .cacheOriginalImage()
                                            .fade(duration: 1)
                                            .onFailure { e in
                                                print("Job failed: \(e.localizedDescription)")
                                            }
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .cornerRadius(20)
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("DefaultCellColor"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    if !userListViewModel.userList.isEmpty {
                        Text("List End")
                            .foregroundColor(.gray)
                            .onAppear {
                                if showOnlySearchedUser == false {
                                    userListViewModel.loadMoreUsers()
                                }
                            }
                    }
                }
                .onAppear {
                    userListViewModel.firstLoadUsers()
                }
                .navigationBarTitle("유저 목록")
                .toolbar {
                    Button(action: {
                        showOnlySearchedUser = false
                        self.searchUserText = ""
                        userListViewModel.userList = []
                        userListViewModel.firstLoadUsers()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}
