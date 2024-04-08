//
//  UserActivityInformationView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI

struct UserActivityInfoView: View {
    var body: some View {
        HStack(spacing: 12) {
            ActivityInfoComponent(title: "아껴 쓴 개수", count: 5)
            Divider()
                .frame(height: 60)
            
            ActivityInfoComponent(title: "나눠 쓴 개수", count: 8)
            Divider()
                .frame(height: 60)
            
            ActivityInfoComponent(title: "바꿔 쓴 개수", count: 13)
            Divider()
                .frame(height: 60)
            
            ActivityInfoComponent(title: "다시 쓴 개수", count: 19)
        }
    }
    
    @ViewBuilder
    private func ActivityInfoComponent(title: String, count: Int) -> some View {
        Button(action: {
            
        }, label: {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
                    .font(ANBDFont.pretendardSemiBold(22))
            }
        })
    }
}

#Preview {
    UserActivityInfoView()
}
