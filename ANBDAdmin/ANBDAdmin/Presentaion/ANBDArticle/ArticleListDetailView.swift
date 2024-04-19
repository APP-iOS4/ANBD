//
//  DetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel
import FirebaseStorage
import CachedAsyncImage

struct ArticleListDetailView: View {
    @Environment(\.presentationMode) var articlePresentationMode
    let article: Article
    let articleUsecase = DefaultArticleUsecase()
    @Binding var deletedArticleID: String?
    @State private var articleDeleteShowingAlert = false
    @State private var articleImageUrls:[URL?] = []
    
    var body: some View {
        List {
            Text("이미지:").foregroundColor(.gray)
            ForEach(articleImageUrls.indices, id: \.self) { index in
                            if let url = articleImageUrls[index] {
                                CachedAsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(height: 300)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                ProgressView()
                            }
                        }
            HStack {
                Text("이미지 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.imagePaths)")
            }
            HStack {
                Text("제목:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.title)")
            }
            HStack {
                Text("게시물ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.id)")
            }
            HStack {
                Text("작성자 닉네임:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.writerNickname)")
            }
            HStack {
                Text("작성자 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.writerID)")
            }
            HStack {
                Text("생성일자:").foregroundColor(.gray)
                Spacer()
                Text(" \(dateFormatter(article.createdAt))")
            }
            HStack {
                Text("카테고리:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.category)")
            }
            HStack {
                Text("내용:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.content)")
            }
            HStack {
                Text("좋아요 수:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.likeCount)")
            }
            HStack {
                Text("댓글 수:").foregroundColor(.gray)
                Spacer()
                Text(" \(article.commentCount)")
            }
        }
        .onAppear {
                    articleLoadImages()
                }
        .navigationBarTitle(article.title)
        .toolbar {
                    Button("Delete") {
                        articleDeleteShowingAlert = true // 경고를 표시
                    }
                }
                .alert(isPresented: $articleDeleteShowingAlert) { // 경고를 표시
                    Alert(
                        title: Text("Delete"),
                        message: Text("Are you sure you want to delete this trade?"),
                        primaryButton: .destructive(Text("Delete")) {
                            Task {
                                do {
                                    try await articleUsecase.deleteArticle(article: article)
                                    deletedArticleID = article.id
                                    articlePresentationMode.wrappedValue.dismiss()
                                } catch {
                                    print("게시물을 삭제하는데 실패했습니다: \(error)")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
        
    }
    func articleLoadImages() {
            let storage = Storage.storage()
            let storageRef = storage.reference()

            for path in article.imagePaths {
                let fullPath = "Article/\(article.id)/\(path)"
                let imageRef = storageRef.child(fullPath)
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error downloading image URL: \(error)")
                    } else {
                        articleImageUrls.append(url)
                    }
                }
            }
        }
}



// 게시물 세부정보 임시 파일.
