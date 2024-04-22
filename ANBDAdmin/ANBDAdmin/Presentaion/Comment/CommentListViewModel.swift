//
//  CommentListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
import ANBDModel
/*
class CommentListViewModel: ObservableObject {
    @Published var commentList: [Comment] = []
    var deletedCommentID: String? // 삭제 변수
    let commentUsecase = DefaultCommentUsecase()

    func loadComments() {
        if commentList.isEmpty || commentList.contains(where: { $0.id == deletedCommentID })  {
            Task {
                do {
                    let comments = try await commentUsecase.loadCommentList()
                                    DispatchQueue.main.async {
                                        self.commentList = comments
                                    }
                } catch {
                    print("댓글 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func loadComment(commentID: String) async throws -> Comment {
        return try await commentUsecase.loadComment(commentID: commentID)
    }
    func searchComment(commentID: String) async {
        do {
            let searchedComment = try await loadComment(commentID: commentID)
            DispatchQueue.main.async {
                self.commentList = [searchedComment]
            }
        } catch {
            print(error)
            DispatchQueue.main.async {
                self.commentList = []
            }
        }
    }
}
*/
