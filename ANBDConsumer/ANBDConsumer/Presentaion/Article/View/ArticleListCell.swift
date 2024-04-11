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
            Image("\(article.imagePaths.first ?? "")")
//                .resizable()
//                .scaledToFit()
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .frame(width: 110, height: 110)
//                .padding(.trailing, 10)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .frame(width: 100, height: 100)
//                .padding(.trailing, 10)
            
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                /*
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "hand.thumbsup")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .padding(.trailing, 5) // 아이콘과 텍스트 사이 간격 조정
                            
                                                    Text("\(article.likeCount)")
//                            Text("99119")
                                .font(.system(size: 12))
                                .multilineTextAlignment(.leading) // 텍스트를 왼쪽 정렬

                        }
                        
                        HStack {
                            Spacer()
                            Image(systemName: "text.bubble")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .padding(.top, 3)
                                .padding(.trailing, 5)
                            
                                                    Text("\(article.commentCount)")
//                            Text("912312399")
                                .font(.system(size: 12))
                                .padding(.top, 3)
                                .multilineTextAlignment(.leading)
                            
                        }
                        .padding(.bottom, 12)
                    }
                    .foregroundStyle(.gray800)
                }
                .frame(height: 35)
                */

                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "hand.thumbsup")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        
                        Text("\(article.likeCount)")
                            .font(.system(size: 12))
                            .padding(.trailing, 10)
                            .padding(.top, 2)
                        
                        
                        Image(systemName: "text.bubble")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                        
                        Text("\(article.commentCount)")
                            .font(.system(size: 12))
                            .padding(.top, 2)

                    }
                }
                .foregroundStyle(.gray800)
                .padding(.top, 18)
            }
        }
    }
}

#Preview {
    ArticleListCell(article: Article(writerID: "writerID", writerNickname: "닉네임1", category: .accua, title: "제목제목", content: "내용내용"))
}
