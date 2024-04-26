//
//  CustomToastView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/25/24.
//

import SwiftUI

enum ToastViewType {
    case report
}

struct CustomToastView: View {
    
    var toastViewType: ToastViewType = .report
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.accentColor)
                .frame(height: 55)
            
            Text(toastTitle)
                .foregroundStyle(.white)
                .font(ANBDFont.SubTitle2)
                .lineLimit(1)
        }
        .padding(.horizontal)
    }
    
    private var toastTitle: String {
        switch toastViewType {
        case .report:
            "신고가 접수되었습니다."
        }
    }
}

#Preview {
    CustomToastView()
}
