//
//  CommunityListCell.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/5/24.
//

import SwiftUI

struct CommunityListCell: View {
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "square.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("제목입니다")
                    .font(ANBDFont.SubTitle1)
                    .foregroundStyle(.gray900)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("이름이름")
                    Text("・")
                        .padding(.leading, -5)
                    Text("23분 전")
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
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.accent)
                        Text("100")
                            .foregroundStyle(.gray800)
                            .padding(.top, 5)
                    }
                    .padding(.top, 10)
                }
                
            }
        }
    }
}

#Preview {
    CommunityListCell()
}
