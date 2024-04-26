//
//  CommentListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
import ANBDModel

struct CommentView: View {
    @ObservedObject var commentViewModel: CommentViewModel
    @State private var showingCommentDeleteAlert = false
    @State private var deleteCommentIndexSet: IndexSet? = nil
    private let articleID: String
    
    init(articleID: String) {
        self.articleID = articleID
        self.commentViewModel = CommentViewModel()
        self.commentViewModel.firstLoadComments(articleID: articleID)
    }
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("내용")
                        .font(.title3)
                        .lineLimit(2)
                        .foregroundColor(.black)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자")
                        .lineLimit(2)
                        .foregroundColor(.black)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("ID")
                        .foregroundColor(.black)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성일자")
                        .font(.title3)
                        .lineLimit(2)
                        .foregroundColor(.black)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 48)
            .padding(.vertical, 5)
            List {
                ForEach(commentViewModel.commentList, id: \.id) { comment in
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.content)")
                                .font(.title3)
                                .lineLimit(1)
                                .foregroundColor(.black)
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.writerNickname)")
                                .lineLimit(2)
                                .foregroundColor(.black)
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.id)")
                                .foregroundColor(.black)
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(DateFormatterSingleton.shared.dateFormatter(comment.createdAt))")
                                .foregroundColor(.black)
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .contextMenu {
                        Button(action: {
                            if let index = self.commentViewModel.commentList.firstIndex(where: { $0.id == comment.id }) {
                                self.deleteCommentIndexSet = IndexSet(integer: index)
                                self.showingCommentDeleteAlert = true
                            }
                        }, label: {
                            HStack {
                                Text("Delete")
                                Spacer()
                                Image(systemName: "trash")
                            }
                        })
                    }
                }
            }
            .alert(isPresented: $showingCommentDeleteAlert) {
                Alert(title: Text("삭제 확인"), message: Text("정말로 이 댓글을 삭제하시겠습니까?"), primaryButton: .destructive(Text("삭제")) {
                    if let deleteIndexSet = self.deleteCommentIndexSet {
                        commentViewModel.deleteComment(articleID: articleID, at: deleteIndexSet)
                    }
                }, secondaryButton: .cancel())
            }
            .onAppear {
                if commentViewModel.canLoadMoreComments {
                    commentViewModel.loadMoreComments(articleID: articleID)
                }
            }
        }
    }
}
