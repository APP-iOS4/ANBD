//
//  CapsuleButtonView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI

struct CapsuleButtonView: View {
    var text: String
    
    /// default : WhiteCapsuleButton
    var isForFiltering: Bool = false
    var buttonColor: Color = .clear
    var fontColor: Color = .gray900
    
    var body: some View {
        HStack {
            Text(text)
            
            if isForFiltering {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
            }
        }
        .font(ANBDFont.Caption3)
        .padding(.horizontal)
        .foregroundStyle(fontColor)
        .background {
            if buttonColor != .clear {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(buttonColor)
                    .frame(height: 30)
            }
        }
        .overlay {
            if buttonColor == .clear {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(.gray400)
                    .frame(height: 30)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        /// 나눠쓰기, 바꿔쓰기 선택 버튼 (Default)
        HStack {
            CapsuleButtonView(text: "나눠쓰기")
            CapsuleButtonView(text: "바꿔쓰기")
        }
        
        /// 필터링 버튼
        HStack {
            CapsuleButtonView(text: "지역", isForFiltering: true)
            CapsuleButtonView(text: "카테고리", isForFiltering: true)
        }
        
        /// 필터링 선택되었을 시 버튼
        HStack {
            CapsuleButtonView(text: "지역", isForFiltering: true, buttonColor: .accent, fontColor: .white)
            CapsuleButtonView(text: "카테고리", isForFiltering: true, buttonColor: .accent, fontColor: .white)
        }
        
        /// 필터링 Sheet 내 버튼
        HStack {
            CapsuleButtonView(text: "지역 2", buttonColor: .lightBlue, fontColor: .accent)
            CapsuleButtonView(text: "카테고리 2", buttonColor: .lightBlue, fontColor: .accent)
        }
    }
}
