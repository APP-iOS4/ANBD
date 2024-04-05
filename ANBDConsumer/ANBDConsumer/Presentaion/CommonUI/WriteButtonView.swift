//
//  WriteButtonView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/5/24.
//

import SwiftUI

struct WriteButtonView: View {
    var body: some View {
        Text("\(Image(systemName: "plus")) 글쓰기")
            .font(ANBDFont.SubTitle1)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding()
            .background(
                Capsule()
                    .fill(Color.accent)
                    .shadow(radius: 4)
            )
            .padding()
    }
}

#Preview {
    WriteButtonView()
}
