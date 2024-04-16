//
//  ArticleListCell.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI
import ANBDModel

struct ArticleListCell: View {

    // enum 부터 protocol까지 따로 빼고싶은데 어떻게 빼야할지 모르겠어서 일단 ListCell에 둠,,,,
    enum ListCellValue {
        case article(Article)
        case trade(Trade)
    }

    protocol ListableItem {
        var title: String { get }
        var writerNickname: String { get }
        var createdAt: String { get }
        var imagePath: String { get }
        var likeCount: Int? { get }
        var commentCount: Int? { get }
    }
    
    @State private var isLiked: Bool = false
    	
    var value: ListCellValue

    var body: some View {
        switch value {
        case .article(let article):
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
            
        case .trade(let trade):
            HStack(alignment: .top) {
                Image("\(trade.imagePaths.first ?? "DummyPuppy1")")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(trade.title)")
                        .font(ANBDFont.SubTitle1)
                        .foregroundStyle(.gray900)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\(trade.writerNickname)")
                        
                        Text("・")
                            .padding(.leading, -5)
                        
                        Text("\(trade.createdAt.relativeTimeNamed)")
                            .padding(.leading, -5)
                        Spacer()
                    }
                    .lineLimit(1)
                    .font(ANBDFont.Caption3)
                    .foregroundStyle(.gray400)
                    Spacer(minLength: 0)
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20)
                            .foregroundStyle(isLiked ? .heartRed : .gray800)
                            .onTapGesture {
                                withAnimation {
                                    isLiked.toggle()
                                }
                            }
                            .padding(.leading, 10)
                    }
                    .foregroundStyle(.gray800)
                }
            }
            .frame(height: 100)
        }
    }
}

#Preview {
    ArticleListCell(value: .article(Article(writerID: "asd", writerNickname: "asd", category: .accua, title: "asd", content: "asd")))
}
