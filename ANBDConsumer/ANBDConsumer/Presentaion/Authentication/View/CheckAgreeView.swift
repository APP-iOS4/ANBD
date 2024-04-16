//
//  CheckAgreeView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct CheckAgreeView: View {
    @Binding var isAgree: Bool
    
    var explainString: String
    var showTermsAction: (() -> ())?
    
    var body: some View {
        HStack {
            Button {
                isAgree.toggle()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(isAgree ? .accent : .primary)
                    
                    Text(explainString)
                        .font(ANBDFont.body1)
                }
            }
            
            Spacer()
            
            if let showTermsAction {
                Button("보기") {
                    showTermsAction()
                }
                .font(ANBDFont.body2)
                .foregroundStyle(.gray400)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CheckAgreeView(isAgree: .constant(true), explainString: "당신의 정보를 강탈하겠습니다. (필수)") {
        
    }
}
