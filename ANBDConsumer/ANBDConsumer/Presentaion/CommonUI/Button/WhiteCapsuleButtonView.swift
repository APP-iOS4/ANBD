//
//  WhiteCapsuleButtonView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/6/24.
//

import SwiftUI

struct WhiteCapsuleButtonView: View {
    var text: String
    var isForFiltering: Bool = false
    
    var body: some View {
        HStack {
            Text(text)
            
            if isForFiltering {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
            }
        }
        .font(ANBDFont.Caption3)
        .padding()
        .foregroundStyle(.gray900)
        .overlay(
            RoundedRectangle(cornerRadius: 25.0)
                .stroke(.gray400)
                .frame(height: 35)
                .foregroundStyle(.clear)
        )
        
    }
}

#Preview {
    VStack(alignment: .leading) {
        WhiteCapsuleButtonView(text: "나눠쓰기")
        WhiteCapsuleButtonView(text: "바꿔쓰기")
        WhiteCapsuleButtonView(text: "서울", isForFiltering: true)
        WhiteCapsuleButtonView(text: "카테고리", isForFiltering: true)
    }
}
