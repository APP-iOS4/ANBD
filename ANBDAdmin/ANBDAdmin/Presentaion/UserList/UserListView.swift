//
//  UserListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct UserListView: View {
    @State private var userList: [User] = []
    let userUsecase = DefaultUserUsecase()
    
    var body: some View {
        List {
            ForEach(userList, id: \.id) { user in
                NavigationLink(destination: UserListDetailView(user: user)) {
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
            Task {
                do {
                    self.userList = try await userUsecase.getUserInfoList()
                } catch {
                    print("사용자 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
        .navigationBarTitle("유저 목록")
    }
}
