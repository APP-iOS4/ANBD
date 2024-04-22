//
//  CommentListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
/*
struct CommentListView: View {
    @StateObject private var commentListViewModel = CommentListViewModel()
    @State private var searchCommentText = ""

    var body: some View {
        VStack {
            TextField("댓글의 ID값으로 검색...", text: $searchCommentText)
                            .textCase(.lowercase)
                            .padding(7)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                            .onSubmit {
                                if !searchCommentText.isEmpty {
                                    Task {
                                        await commentListViewModel.searchComment(commentID: searchCommentText)
                                    }
                                }
                            }
                            .textInputAutocapitalization(.characters)// 항상 대문자로 입력받음
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("댓글이 달린 게시물 제목")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("댓글 내용")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자 닉네임")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("생성일자")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView{
                LazyVStack {
                    ForEach(commentListViewModel.commentList, id: \.id) { comment in
                        NavigationLink(destination: CommentListDetailView(comment: comment, deletedCommentID: $commentListViewModel.deletedCommentID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(comment.nickname)")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(comment.email)")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(comment.userLevel)")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(dateFormatter(comment.createdAt))")
                                        .foregroundColor(.black)
                                }
                                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .onAppear {
                    commentListViewModel.loadComments()
                }
                .navigationBarTitle("게시물 목록")
                .toolbar {
                            Button(action: {
                                commentListViewModel.loadComments()
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

*/
