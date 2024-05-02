//
//  ToastView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/25/24.
//

import SwiftUI

struct ToastView: View {
    var style: ToastStyle
    var message: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(style.themeColor)
                .frame(height: 55)
            
            Text("\(message)")
                .foregroundStyle(Color.white)
                .font(ANBDFont.SubTitle2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(10)
        }
        .padding()
    }
}

#Preview {
    ToastView(style: .error, message: "에러가 발생했습니다.")
}
