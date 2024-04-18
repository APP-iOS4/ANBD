//
//  TextFieldModifier.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/8/24.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .foregroundStyle(.gray900)
            .padding(12)
            .textInputAutocapitalization(.never) // 처음 문자 자동으로 대문자로 바꿔주는 기능 막기
            .overlay(
                RoundedRectangle(cornerRadius: 10.0)
                    .stroke(.gray, lineWidth: 1)
            )
    }
}
