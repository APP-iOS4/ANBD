//
//  CommentListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
import ANBDModel

class CommentViewModel: ObservableObject {
    @Published var commentList: [Comment] = []
    var deletedCommentID: String?
    let commentUsecase = DefaultCommentUsecase()
    @Published var canLoadMoreComments: Bool = true

    
    func firstLoadComments(articleID: String) {
        if commentList.isEmpty {
            Task {
                do {
                    let comments = try await commentUsecase.loadCommentList(articleID: articleID)
                    DispatchQueue.main.async {
                        self.commentList = comments
                        self.canLoadMoreComments = true
                    }
                } catch {
                    print("댓글 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func loadMoreComments(articleID: String){
        guard canLoadMoreComments else { return }

        Task {
            do {
                let comments = try await commentUsecase.loadCommentList(articleID: articleID)
                DispatchQueue.main.async {
                    self.commentList.append(contentsOf: comments)
                    if comments.count < 10 {
                        self.canLoadMoreComments = false
                    }
                }
            } catch {
                print("게시물 목록을 가져오는데 실패했습니다: \(error)")
            }
        }
    }
    func deleteComment(articleID: String, at offsets: IndexSet) {
        offsets.forEach { index in
            let comment = commentList[index]
            Task {
                do {
                    try await commentUsecase.deleteComment(articleID: articleID, commentID: comment.id)
                    DispatchQueue.main.async {
                        self.commentList.remove(at: index)
                    }
                } catch {
                    print("댓글을 삭제하는데 실패했습니다: \(error)")
                }
            }
        }
    }
}
