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
    var category: ANBDCategory
    
    @State private var tmpSelectedItemCategories: [ItemCategory] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CapsuleButtonView(text: "카테고리 \(tmpSelectedItemCategories.count)", buttonColor: .lightBlue, fontColor: .accent)
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing, 250)
                    
                Spacer()
            }
            
            ScrollView {
                ForEach(ItemCategory.allCases, id: \.self) { item in
                    Button(action: {
                        if tmpSelectedItemCategories.contains(item) {
                            if let firstIndex = tmpSelectedItemCategories.firstIndex(of: item) {
                                tmpSelectedItemCategories.remove(at: firstIndex)
                            }
                        } else {
                            tmpSelectedItemCategories.append(item)
                        }
                    }, label: {
                        CheckboxView(isChecked: tmpSelectedItemCategories.contains(item), text: item.rawValue)
                    })
                    .padding(.vertical, 5)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Button(action: {
                    tmpSelectedItemCategories = []
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
                    tradeViewModel.selectedItemCategories = tmpSelectedItemCategories
                    Task {
                        await tradeViewModel.reloadFilteredTrades(category:category)
                        isShowingCategory.toggle()
                    }
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
        .onAppear {
            tmpSelectedItemCategories = tradeViewModel.selectedItemCategories
        }
    }
}


//#Preview {
//    CategoryBottomSheet(isShowingCategory: .constant(true))
//        .environmentObject(TradeViewModel())
//}
