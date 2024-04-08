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
            .padding()
            .foregroundStyle(.lightBlue)
            .overlay(
                Text("\(text)")
                    .font(ANBDFont.Caption3)
                    .foregroundStyle(.accent)
            )
        
//        Text(text)
//            .font(ANBDFont.Caption3)
//            .foregroundStyle(.accent)
//            .padding()
//            .overlay(RoundedRectangle(cornerRadius: 25).foregroundStyle(.lightAccent))
    }
}

#Preview {
    LightBlueCapsuleButtonView(text: "지역")
}
