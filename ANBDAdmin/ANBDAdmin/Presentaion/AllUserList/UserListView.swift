//
//  UserListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct UserListView: View {
    @StateObject private var userListViewModel = UserListViewModel()
    @State private var searchUserText = "" // 검색 텍스트 추적하는 변수
    let userLevel: UserLevel
    
    var body: some View {
        VStack {
            TextField("검색...", text: $searchUserText)
                .textCase(.lowercase)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            
            List {
                            ForEach(userListViewModel.userList.filter({
                                ($0.userLevel == userLevel) && (searchUserText.isEmpty ? true : $0.nickname.contains(searchUserText) || $0.id.contains(searchUserText))
                            }), id: \.id) { user in
                                NavigationLink(destination: UserListDetailView(user: user, initialUserLevel: userLevel)) {
                                    HStack{
                                VStack(alignment: .leading) {
                                    Text("닉네임")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(user.nickname)")
                                        .font(.title2)
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("이메일")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(user.email)")
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("유저 권한")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(user.userLevel)")
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Spacer()
                                VStack(alignment: .leading) {
                                    if let imageUrl = URL(string: user.profileImage) {
                                        AsyncImage(url: imageUrl) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable().frame(width: 40, height: 40)
                                            case .failure:
                                                Text("Failed to load image")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
            }
            .onAppear {
                userListViewModel.loadUsers()
            }
            .navigationBarTitle("유저 목록")
        }
    }
}
