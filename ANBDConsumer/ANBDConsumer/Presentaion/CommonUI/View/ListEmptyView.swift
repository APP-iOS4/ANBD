//
//  ListEmptyView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/18/24.
//

import SwiftUI

struct ListEmptyView: View {
    let description: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "tray")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60)
                .padding(.bottom, 10)
            
            HStack {
                Spacer()
                
                Text("\(description)")
                    .multilineTextAlignment(.center)
                    .font(ANBDFont.body1)
                
                Spacer()
            }
            Spacer()
        }
        .foregroundStyle(Color.gray400)
        .background(Color.gray50)
    }
}

#Preview {
    ListEmptyView(description: "불량마루님의\n아껴쓰기 활동이 없습니다.")
}
