//
//  BlueCapsuleButtonView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/5/24.
//

import SwiftUI

struct BlueCapsuleButtonView: View {
    var text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .frame(height: 35)
            .foregroundStyle(.accent)
            .overlay(
                Text("\(text)")
                    .font(ANBDFont.Caption3)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundStyle(.white)
            )
    }
}

#Preview {
    BlueCapsuleButtonView(text: "지역")
}
