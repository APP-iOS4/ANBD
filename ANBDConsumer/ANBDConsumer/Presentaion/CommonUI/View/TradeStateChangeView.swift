//
//  TradeStateChangeView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import ANBDModel

struct TradeStateChangeView: View {
    //@Binding var isTrading: Bool
    @Binding var tradeState: TradeState
    @State private var isShowingConfirm: Bool = false
    @State private var isShowingAlert: Bool = false
    var fontSize: CGFloat = 14
    
    var body: some View {
        Button(action: {
            isShowingConfirm.toggle()
        }, label: {
            HStack {
                Text("\(tradeState.description)")
                    .font(ANBDFont.pretendardSemiBold(fontSize))
//                    .font(ANBDFont.SubTitle3)
                
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
            }
            .foregroundStyle(.gray900)
        })
        .confirmationDialog("", isPresented: $isShowingConfirm) {
            Button("거래 중") {
                if tradeState == .finish {
                    isShowingAlert.toggle()
                }
            }
            
            Button("거래 완료") {
                if tradeState == .trading {
                    isShowingAlert.toggle()
                }
            }
        } message: {
            Text("상태변경")
        }
        .alert("해당 게시글의 상태를 \(tradeState == .finish ? "거래 중으" : "거래 완료")로 변경하시겠습니까?", isPresented: $isShowingAlert) {
            Button("변경") {
                if tradeState == .trading {
                    tradeState = .finish
                } else {
                    tradeState = .trading
                }
            }
            
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    TradeStateChangeView(tradeState: .constant(.trading))
}
