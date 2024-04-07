//
//  OtherSettingsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct OtherSettingsView: View {
    @State var isShowingPolicyView: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            
            Button(action: {
                // 각 리스트로 이동할 뷰
            }, label: {
                Text("내가 찜한 나눔 ・ 거래 보기")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.SubTitle2)
                    .padding()
            })
            
            Divider()
            
            Button(action: {
                isShowingPolicyView.toggle()
            }, label: {
                Text("약관 및 정책")
                    .foregroundStyle(Color.gray900)
                    .font(ANBDFont.SubTitle2)
                    .padding()
            })
            
            Divider()
        }
        .navigationDestination(isPresented: $isShowingPolicyView) {
            Text("약관 및 정책")
        }
    }
}

#Preview {
    OtherSettingsView()
}
