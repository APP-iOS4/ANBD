//
//  ItemCategoryPickerMenu.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ItemCategoryPickerMenu: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @Binding var isShowingMenuList: Bool
    @State var selectedItem: ItemCategory = .digital
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Button(action: {
                    withAnimation {
                        isShowingMenuList.toggle()
                    }
                    
                    downKeyboard()
                }, label: {
                    HStack {
                        Text("\(selectedItem.rawValue)")
                            .font(ANBDFont.SubTitle2)
                            .foregroundStyle(Color.gray900)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .rotationEffect(Angle(degrees: isShowingMenuList ? 180 : 0))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .foregroundStyle(Color.gray900)
                })
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray200, lineWidth: 1)
                }
                
                if isShowingMenuList {
                    pickerListView(selectedItem)
                }
            }
        }
    }
    
    //MARK: - picker view
    
    @ViewBuilder
    func pickerListView(_ selectedItem: ItemCategory) -> some View {
        ScrollView {
            LazyVStack(alignment: .trailing) {
                ForEach(ItemCategory.allCases, id: \.self) { item in
                    VStack {
                        Button(action: {
                            self.selectedItem = item
                            tradeViewModel.selectedItemCategory = item
                            isShowingMenuList.toggle()
                        }, label: {
                            Text(item.rawValue)
                                .font(ANBDFont.body1)
                                .foregroundStyle(Color.gray900)
                                .padding(.vertical, 5)
                                .frame(width: 200)
                                .overlay(alignment: .leading) {
                                    if selectedItem == item {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.gray900)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        })
                    }
                }
            }
            .padding(.vertical)
        }
        //.frame(width: 250, height: 300)
        .background {
            if #available(iOS 17.0, *) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .stroke(Color.gray100, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray100, lineWidth: 1)
                    }
            }
        }
        .shadow(radius: 10)
    }
}

#Preview {
    ItemCategoryPickerMenu(isShowingMenuList: .constant(false), selectedItem: .beautyCosmetics)
}

extension ItemCategoryPickerMenu {
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
