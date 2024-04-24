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
    let articleUsecase = DefaultArticleUsecase()
    let article: Article
    @Binding var deletedArticleID: String?
    @State private var articleDeleteShowingAlert = false
    @State private var articleImageUrls:[URL?] = []
    @State private var articleImageLoaded = false
    @State private var isLinkActive = false
    
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
                Text("게시글ID:").foregroundColor(.gray)
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
            HStack {
                NavigationLink(destination: CommentView(articleID: article.id).font(.title3)) {
                    Text("댓글 목록")
                }
            }
        }
        .onAppear {
            if articleImageLoaded == false{
                articleLoadImages()
                articleImageLoaded.toggle()
            }
        }
        .navigationBarTitle(article.title)
        .toolbar {
            Button("삭제") {
                articleDeleteShowingAlert = true // 경고를 표시
            }
        }
        .alert(isPresented: $articleDeleteShowingAlert) { // 경고를 표시
            Alert(
                title: Text("삭제"),
                message: Text("해당게시글을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    Task {
                        do {
                            try await articleUsecase.deleteArticle(article: article)
                            deletedArticleID = article.id
                            articlePresentationMode.wrappedValue.dismiss()
                        } catch {
                            print("게시글을 삭제하는데 실패했습니다: \(error)")
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
