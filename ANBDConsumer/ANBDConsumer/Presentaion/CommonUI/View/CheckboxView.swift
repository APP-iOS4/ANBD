//
//  CheckboxView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI

struct CheckboxView: View {
    var isChecked: Bool
    var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundStyle(isChecked ? .accent : .gray800)
            
            Text(text)
                .font(ANBDFont.pretendardRegular(18))
                .foregroundStyle(.gray900)
            Spacer()
        }
    }
}

//#Preview {
//    CheckboxView()
//}
