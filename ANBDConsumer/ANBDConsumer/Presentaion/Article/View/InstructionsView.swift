//
//  InstructionsView.swift
//  ANBDConsumer
//
//  Created by 기 표 on 4/8/24.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .foregroundStyle(.lightAccent)
                .frame(height: 50)
            
            HStack {
                Text("안내")
                    .font(ANBDFont.SubTitle2)
                
                Text("명예훼손, 광고/홍보 목적의 글은 올리실 수 없어요.")
                    .font(ANBDFont.pretendardMedium(15))
            }
            .foregroundStyle(.gray50)
        }
        .padding(.horizontal)
    }
}

#Preview {
    InstructionsView()
}
