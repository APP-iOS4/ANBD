//
//  TradeStateChangeView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI

struct TradeStateChangeView: View {
    @Binding var isTrading: Bool
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingAlert: Bool = false
    
    var body: some View {
        Button(action: {
            isShowingConfirm.toggle()
        }, label: {
            HStack {
                Text(isTrading ? "거래 중" : "거래 완료")
                    .font(ANBDFont.SubTitle3)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
            }
            .foregroundStyle(.gray900)
        })
        .confirmationDialog("", isPresented: $isShowingConfirm) {
            Button("거래 중") {
                if !isTrading {
                    isShowingAlert.toggle()
                }
            }
            
            Button("거래 완료") {
                if isTrading {
                    isShowingAlert.toggle()
                }
            }
        } message: {
            Text("상태변경")
        }
        .alert("해당 게시글의 상태를 \(isTrading ? "거래 완료" : "거래 중으")로 변경하시겠습니까?", isPresented: $isShowingAlert) {
            Button("변경") {
                isTrading.toggle()
            }
            
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    TradeStateChangeView(isTrading: .constant(true))
}
