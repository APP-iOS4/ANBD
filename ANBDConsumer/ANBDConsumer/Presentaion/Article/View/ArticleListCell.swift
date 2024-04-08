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
            Image("DummyImage1")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 110, height: 110)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(article.title)")
                    .font(ANBDFont.SubTitle1)
                    .foregroundStyle(.gray900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 15)

                HStack {
                    Text("\(article.writerNickname)")
                    Text("・")
                        .padding(.leading, -5)
                    Text("\(article.createdAt.relativeTimeNamed)")
                        .padding(.leading, -5)
                    Spacer()
                }
                .font(ANBDFont.Caption3)
                .foregroundStyle(.gray400)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "hand.thumbsup.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 21, height: 21)
                            .foregroundStyle(.accent)
                        Text("\(article.likeCount)")
                            .font(ANBDFont.body2)
                            .foregroundStyle(.gray800)
                            .padding(.top, 5)
                            .padding(.trailing, 10)
                        
                        Image(systemName: "text.bubble.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.accent)
                            .padding(.top, 3)
                        Text("\(article.commentCount)")
                            .font(ANBDFont.body2)
                            .foregroundStyle(.gray800)
                            .padding(.top, 5)
                        
                    }
                    .padding(.top)
//                    .padding(.leading, 0)
                }
                
            }
        }
    }
}

#Preview {
    ArticleListCell(article: Article(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "제목제목", content: "내용내용"))
}
