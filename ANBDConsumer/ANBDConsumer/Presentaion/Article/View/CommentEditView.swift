//
//  CommentEditView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/20/24.
//

import SwiftUI
import ANBDModel

struct CommentEditView: View {
    @EnvironmentObject private var articleViewModel: ArticleViewModel
    
    @State private var content : String = ""
    @State var placeHolder : String = "댓글을 입력해주세요."
    @State private var isShowingCustomAlert: Bool = false

    @Binding var isShowingCommentEditView: Bool
    
    @Environment(\.dismiss) private var dismiss

    var comment: Comment?
    var isEditComment: Bool
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Divider()
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text(placeHolder)
                                .foregroundStyle(.gray400)
                                .font(ANBDFont.body1)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
                        TextEditor(text: $content)
                            .scrollContentBackground(.hidden)
                            .font(ANBDFont.body1)
                            .padding(.horizontal, 15)
                            .onAppear {
                                if !isEditComment {
                                    if let comment = comment {
                                        self.content = comment.content
                                    }
                                }
                            }
                    }
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                Task {
                                    if !isEditComment {
                                        if var comment = comment {
                                            comment.content = self.content
                                            
                                            await articleViewModel.updateComment(comment: comment)
                                            await articleViewModel.loadCommentList(articleID: articleViewModel.article.id)
                                        }
                                    }
                                }
                                self.isShowingCommentEditView.toggle()
                            } label: {
                                Text("완료")
                            }
                            .disabled(content.isEmpty)
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                if !isEditComment {
                                    if let comment = comment {
                                        let isContentChanged = content != comment.content
                                        if isContentChanged {
                                            isShowingCustomAlert.toggle()
                                        } else {
                                            isShowingCommentEditView.toggle()
                                        }
                                    }
                                } else {
                                    isShowingCommentEditView.toggle()
                                }
                            } label: {
                                Text("취소")
                            }
                        }
                    }
                }
                .navigationTitle("댓글 수정")
                .navigationBarTitleDisplayMode(.inline)
            }
            
            if isShowingCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlert, viewType: .commentEdit) {
                    dismiss()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
