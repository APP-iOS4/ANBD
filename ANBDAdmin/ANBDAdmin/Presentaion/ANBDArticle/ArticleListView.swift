//
//  UserListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ArticleListView: View {
    @State private var articleList: [Article] = []
    @State private var deletedArticleID: String? // 삭제 상태 변수
    let articleUsecase = DefaultArticleUsecase()
    
    var body: some View {
        List {
            ForEach(articleList, id: \.id) { article in
                NavigationLink(destination: ArticleListDetailView(article: article, deletedArticleID: $deletedArticleID)) {
                    HStack{
                        VStack(alignment: .leading) {
                            Text("제목")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(article.title)")
                                .font(.title3)
                        }
                        .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("작성자 닉네임")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(article.writerNickname)")
                        }
                        .frame(minWidth: 0, maxWidth: 250, alignment: .leading)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("생성일자")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(dateFormatter(article.createdAt))")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                }
            }
        }

        .onAppear {
            if articleList.isEmpty || articleList.contains(where: { $0.id == deletedArticleID })  {
                Task {
                    do {
                        self.articleList = try await articleUsecase.loadArticleList()
                    } catch {
                        print("게시물 목록을 가져오는데 실패했습니다: \(error)")
                    }
                }
            }
        }
        .navigationBarTitle("게시물 목록")
    }
}
