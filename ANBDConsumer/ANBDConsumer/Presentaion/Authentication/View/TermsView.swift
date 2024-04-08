//
//  TermsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Text("개인정보 처리 방침")
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 20)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                }
                .frame(width: 20, height: 20)
                .tint(.primary)
            }
            
            Spacer()
            
            VStack {
                Text("당신의 개인정보를 가져갈 것입니다.")
                Text("거부할 수 없으셈 ㅋㅋ")
            }
            
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    TermsView()
}
