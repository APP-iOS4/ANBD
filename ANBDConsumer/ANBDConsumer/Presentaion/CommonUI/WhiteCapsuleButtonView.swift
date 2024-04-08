//
//  WhiteCapsuleButtonView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/6/24.
//

import SwiftUI

struct WhiteCapsuleButtonView: View {
    var text: String
    
    var body: some View {
        Text("\(text)")
            .font(ANBDFont.Caption3)
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundStyle(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(.gray)
                    .frame(height: 35)
                    .foregroundStyle(.clear)
            )
    }
}

#Preview {
    WhiteCapsuleButtonView(text: "나눠쓰기")
}
