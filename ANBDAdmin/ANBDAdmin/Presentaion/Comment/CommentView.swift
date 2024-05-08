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
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성자")
                        .lineLimit(2)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("ID")
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("작성일자")
                        .font(.title3)
                        .lineLimit(2)
                }
                .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 48)
            .padding(.vertical, 5)
            List {
                HStack{
                    Spacer()
                    Text("각 댓글은 눌러서 홀드하면 삭제할 수 있습니다.")
                        .foregroundColor(.gray)
                        .font(ANBDFont.body1)
                    Spacer()
                }
                .alignmentGuide(
                                .listRowSeparatorLeading
                            ) { dimensions in
                                dimensions[.leading]
                            }
                ForEach(commentViewModel.commentList, id: \.id) { comment in
                    HStack{
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.content)")
                                .font(.title3)
                                .foregroundColor(Color("DefaultTextColor"))
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.writerNickname)")
                                .lineLimit(2)
                                .foregroundColor(Color("DefaultTextColor"))
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(comment.id)")
                                .foregroundColor(Color("DefaultTextColor"))
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Divider()
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("\(DateFormatterSingleton.shared.dateFormatter(comment.createdAt))")
                                .foregroundColor(Color("DefaultTextColor"))
                        }
                        .frame(minWidth: 0, maxWidth: 200, alignment: .leading)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundStyle(Color("DefaultCellColor"))
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
