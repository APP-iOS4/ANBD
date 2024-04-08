//
//  CategoryBottomSheet.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct CategoryBottomSheet: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @Binding var isShowingCategory: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
              ScrollView {
                  HStack {
                      LightBlueCapsuleButtonView(text: "카테고리 \(tradeViewModel.selectedItemCategories.count)")
                          .frame(width: 100)
                          .padding()
                      Spacer()
                  }
                ForEach(ItemCategory.allCases, id: \.self) { item in
                    CheckboxView(isChecked: $tradeViewModel.isSelectedItemCategories[1], text: item.labelText)
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
