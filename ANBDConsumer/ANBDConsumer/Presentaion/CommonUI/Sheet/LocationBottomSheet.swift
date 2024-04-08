//
//  LocationBottomSheet.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct LocationBottomSheet: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @Binding var isShowingLocation: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                HStack {
                    LightBlueCapsuleButtonView(text: "지역 \(tradeViewModel.selectedLocations.count)")
                        .frame(width: 100)
                        .padding()
                    Spacer()
                }
                ForEach(Location.allCases, id: \.self) { item in
                    CheckboxView(isChecked: $tradeViewModel.isSelectedLocations[1], text: item.description)
                }
                .padding(.horizontal)
                Spacer()
            }
            
            HStack {
                //초기화
                //적용하기
            }
        }
    }
}
