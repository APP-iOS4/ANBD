//
//  BlueSquareButton.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct BlueSquareButton: View {
    var cornerRadius: CGFloat
    var height: CGFloat
    var foreGroundColor: Color
    
    var title: String
    var isDisabled: Bool
    
    var buttonAction: () -> () = { }
    
    init(
        cornerRadius: CGFloat = 14,
        height: CGFloat = 56,
        foreGroundColor: Color = .accent,
        title: String = "버튼 타이틀",
        isDisabled: Bool = false,
        buttonAction: @escaping () -> Void = { }
    ) {
        self.cornerRadius = cornerRadius
        self.height = height
        self.foreGroundColor = foreGroundColor
        self.title = title
        self.isDisabled = isDisabled
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(!isDisabled ? .accent : .gray200)
                .overlay {
                    Text(title)
                        .font(ANBDFont.SubTitle1)
                        .foregroundStyle(.white)
                }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .disabled(isDisabled)
    }
}

#Preview {
    BlueSquareButton(isDisabled: true)
}
