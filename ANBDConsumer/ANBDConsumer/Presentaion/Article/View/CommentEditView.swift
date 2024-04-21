//
//  CommentEditView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/20/24.
//

import SwiftUI
import ANBDModel

struct CommentEditView: View {
    
    @State private var content : String = ""
    @State var placeHolder : String = "댓글을 입력해주세요."
    
    @Binding var isShowingCommentEditView: Bool
    
    var comment: Comment
    var body: some View {
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

                        }
                }
//                Spacer()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            self.isShowingCommentEditView.toggle()
                        } label: {
                            Text("완료")
                        }
                        .disabled(content.isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            isShowingCommentEditView.toggle()
                        } label: {
                            Text("취소")
                        }
                    }
                }
            }
            .navigationTitle("댓글 수정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CommentEditView(isShowingCommentEditView: .constant(true), comment: Comment(articleID: "", writerID: "", writerNickname: "", writerProfileImageURL: "", content: "asdasd"))
}
