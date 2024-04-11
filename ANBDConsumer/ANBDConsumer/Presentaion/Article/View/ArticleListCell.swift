//
//  ArticleListCell.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel

struct ArticleListCell: View {
    var article: Article
    
    var body: some View {
        HStack(alignment: .top) {
            Image("\(article.imagePaths.first ?? "DummyPuppy1")")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(article.title)")
                    .font(ANBDFont.SubTitle1)
                    .foregroundStyle(.gray900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("\(article.writerNickname)")
                    Text("・")
                        .padding(.leading, -5)
                    Text("\(article.createdAt.relativeTimeNamed)")
                        .padding(.leading, -5)
                    Spacer()
                }
                .lineLimit(1)
                .font(ANBDFont.Caption3)
                .foregroundStyle(.gray400)
                Spacer(minLength: 0)
                
                
                HStack {
                    Spacer()
                    Image(systemName: "hand.thumbsup")
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Text("\(article.likeCount)")
                        .font(.system(size: 12))
                        .padding(.trailing, 10)
                        .padding(.top, 2)
                    
                    Image(systemName: "text.bubble")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Text("\(article.commentCount)")
                        .font(.system(size: 12))
                        .padding(.top, 2)
                }
                .foregroundStyle(.gray800)
            }
        }
        .frame(height: 100)
    }
}
#Preview {
    ArticleListCell(article: Article(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "제목제목", content: "내용내용"))
}
