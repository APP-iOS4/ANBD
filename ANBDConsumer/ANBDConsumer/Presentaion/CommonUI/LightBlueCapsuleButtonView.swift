//
//  LightBlueCapsuleButtonView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI

struct LightBlueCapsuleButtonView: View {
    var text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .frame(height: 35)
            .foregroundStyle(.white) //lightBlue로 바꾸기
            .overlay(
                Text("\(text)")
                    .font(ANBDFont.Caption3)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundStyle(.accent)
            )
    }
}

#Preview {
    LightBlueCapsuleButtonView(text: "지역")
}
