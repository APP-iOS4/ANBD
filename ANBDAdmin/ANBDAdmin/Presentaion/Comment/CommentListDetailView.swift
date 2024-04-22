//
//  CommentListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
import ANBDModel


struct CommentListDetailView: View {
    @Environment(\.presentationMode) var commentPresentationMode
    let comment: Comment
    let commentUsecase = DefaultCommentUsecase()
    @Binding var deletedCommentID: String?
    @State private var commentDeleteShowingAlert = false
    
    var body: some View {
        List {
            HStack {
                Text("댓글이 달린 게시물 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(comment.articleID)")
            }
            HStack {
                Text("댓글ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(comment.id)")
            }
            HStack {
                Text("작성자 닉네임:").foregroundColor(.gray)
                Spacer()
                Text(" \(comment.writerNickname)")
            }
            HStack {
                Text("작성자 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(comment.writerID)")
            }
            HStack {
                Text("내용:").foregroundColor(.gray)
                Spacer()
                Text(" \(comment.content)")
            }
            HStack {
                Text("생성일자:").foregroundColor(.gray)
                Spacer()
                Text(" \(dateFormatter(comment.createdAt))")
            }
        }
        .navigationBarTitle("\(comment.writerNickname) 님의 댓글")
        .toolbar {
            Button("삭제") {
                commentDeleteShowingAlert = true // 경고를 표시
            }
        }
        .alert(isPresented: $commentDeleteShowingAlert) { // 경고를 표시
            Alert(
                title: Text("삭제"),
                message: Text("해당 댓글을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    Task {
                        do {
                            try await commentUsecase.deleteComment(articleID: comment.articleID, commentID: comment.id)
                            deletedCommentID = comment.id
                            commentPresentationMode.wrappedValue.dismiss()
                        } catch {
                            print("댓글을 삭제하는데 실패했습니다: \(error)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

