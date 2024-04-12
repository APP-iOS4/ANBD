//
//  DetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ArticleListDetailView: View {
    @Environment(\.presentationMode) var articlepresentationMode
    let article: Article
    let articleUsecase = DefaultArticleUsecase()
    @Binding var deletedArticleID: String?

    
    var body: some View {
        List {
            Text("제목:").foregroundColor(.gray) + Text(" \(article.title)")
            Text("게시물ID:").foregroundColor(.gray) + Text(" \(article.id)")
            Text("작성자 닉네임:").foregroundColor(.gray) + Text(" \(article.writerNickname)")
            Text("작성자 ID:").foregroundColor(.gray) + Text(" \(article.writerID)")
            Text("생성일자:").foregroundColor(.gray) + Text(" \(dateFormatter(article.createdAt))")
            Text("카테고리:").foregroundColor(.gray) + Text(" \(article.category)")
            Text("내용:").foregroundColor(.gray) + Text(" \(article.content)")
            Text("이미지:").foregroundColor(.gray) + Text(" \(article.imagePaths )")
            Text("좋아요 수:").foregroundColor(.gray) + Text(" \(article.likeCount)")
            Text("댓글 수:").foregroundColor(.gray) + Text(" \(article.commentCount)")
        }
        .navigationBarTitle(article.title)
        .toolbar {
            Button("Delete") {
                Task {
                    do {
                        try await articleUsecase.deleteArticle(article: article)
                        deletedArticleID = article.id
                        articlepresentationMode.wrappedValue.dismiss()
                    } catch {
                        print("게시물을 삭제하는데 실패했습니다: \(error)")
                    }
                }
            }
        }
    }
}



// 게시물 세부정보 임시 파일.
