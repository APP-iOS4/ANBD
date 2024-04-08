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
            HStack {
                CapsuleButtonView(text: "카테고리 \(tradeViewModel.selectedItemCategories.count)", buttonColor: .lightBlue, fontColor: .accent)
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing, 250)
                    
                Spacer()
            }
            
            ScrollView {
                ForEach(ItemCategory.allCases, id: \.self) { item in
                    Button(action: {
                        if tradeViewModel.selectedItemCategories.contains(item) {
                            tradeViewModel.selectedItemCategories.remove(item)
                        } else {
                            tradeViewModel.selectedItemCategories.insert(item)
                        }
                    }, label: {
                        CheckboxView(isChecked: tradeViewModel.selectedItemCategories.contains(item), text: item.labelText)
                    })
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Button(action: {
                    tradeViewModel.selectedItemCategories = []
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.gray100)
                        
                        Text("초기화")
                            .foregroundStyle(.gray900)
                    }
                })
                .padding(.trailing, 40)
                
                Button(action: {
                    isShowingCategory.toggle()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                        
                        Text("적용하기")
                            .foregroundStyle(.white)
                    }
                })
                .padding(.leading, -40)
            }
            .frame(height: 50)
            .padding()
        }
    }
}


#Preview {
    CategoryBottomSheet(isShowingCategory: .constant(true))
        .environmentObject(TradeViewModel())
}
