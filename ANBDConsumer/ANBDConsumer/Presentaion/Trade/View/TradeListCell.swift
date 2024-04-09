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
            
            Image(.dummyImage1)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 110, height: 110)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(trade.title)")
                    .font(ANBDFont.SubTitle1)
                    .foregroundStyle(.gray900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 15)
                
                HStack {
                    Text("\(trade.writerNickname)")
                    Text("・")
                        .padding(.leading, -5)
                    Text("\(trade.createdAt.relativeTimeNamed)")
                        .padding(.leading, -5)

                    Spacer()
                }
                .font(ANBDFont.SubTitle3)
                .foregroundStyle(.gray500)
                
                HStack {
                    if trade.category == .nanua {
                        Text("무료나눔")
                            .fontWeight(.bold)
                    } else {
                        HStack {
                            Text("\(trade.myProduct)")
                            
                            Image(systemName: "arrow.left.and.right")
                            
                            if let want = trade.wantProduct {
                                Text("\(want)")
                            } else {
                                Text("제시")
                            }
                        }
                    }
                }//HStack
                .font(ANBDFont.SubTitle2)
                .foregroundStyle(.gray900)

            }//VStack
            Spacer()
            
            VStack {
                Spacer()
                
                Button(action: {
                    isLiked.toggle()
                }, label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 20)
                        .foregroundStyle(isLiked ? .heartRed : .gray200)
                        .padding(.leading, 10)
                })
            }
        }
    }
}
