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
    let articleID: String
    
    init(articleID: String) {
        self.articleID = articleID
        self.commentViewModel = CommentViewModel()
        self.commentViewModel.firstLoadComments(articleID: articleID)
    }
    
    var body: some View {
        HStack{
            Spacer()
            VStack(alignment: .leading) {
                Text("내용")
                    .font(.title3)
                    .lineLimit(2)
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
            Divider()
            Spacer()
            VStack(alignment: .leading) {
                Text("작성자")
                    .lineLimit(2)
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
            Divider()
            Spacer()
            VStack(alignment: .leading) {
                Text("작성일자")
                    .foregroundColor(.black)
            }
            .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 30)
        .padding(.horizontal, 15)
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
                    .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                    Divider()
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("\(comment.writerNickname)")
                            .lineLimit(2)
                            .foregroundColor(.black)
                    }
                    .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                    Divider()
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("\(dateFormatter(comment.createdAt))")
                            .foregroundColor(.black)
                    }
                    .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .onDelete { offsets in
                commentViewModel.deleteComment(articleID: articleID, at: offsets)
            }
        }
        .onAppear {
            if commentViewModel.canLoadMoreComments {
                commentViewModel.loadMoreComments(articleID: articleID)
            }
        }
    }
}

