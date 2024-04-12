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
    @Binding var isShowingCustomAlert: Bool
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
                    isShowingCustomAlert.toggle()
                }
            }
            
            Button("거래 완료") {
                if tradeState == .trading {
                    isShowingCustomAlert.toggle()
                }
            }
        } message: {
            Text("상태변경")
        }
    }
}

#Preview {
    TradeStateChangeView(tradeState: .constant(.trading), isShowingCustomAlert: .constant(false))
}
