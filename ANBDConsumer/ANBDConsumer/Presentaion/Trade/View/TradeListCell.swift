//
//  TradeListCell.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct TradeListCell: View {
    //임시
    @State var isLiked: Bool = false
    var trade: Trade
    
    var body: some View {
        
        HStack(alignment: .top) {
            //            AsyncImage(url: URL(string: trade.imagePaths.first ?? "DummyImage1"), content: { img in
            //                img.resizable()
            //                    .scaledToFit()
            //                    .clipShape(RoundedRectangle(cornerRadius: 8))
            //                    .frame(width: 110, height: 110)
            //            }, placeholder: {
            //                ProgressView()
            //            })
            //            .padding(.trailing, 10)
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
                    
                    Button(action: {
                        isLiked.toggle()
                    }, label: {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 20)
                            .foregroundStyle(isLiked ? .heartRed : .gray800)
                            .padding(.leading, 10)
                    })
                }
                .foregroundStyle(.gray800)
            }
        }
        .frame(height: 100)
    }
}
