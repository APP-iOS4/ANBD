//
//  PickerMenu.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct LocationPickerMenu: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @Binding var isShowingMenuList: Bool
    @Binding var selectedItem: Location
    
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
                        Text("\(selectedItem.description)")
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
    
    @ViewBuilder
    func pickerListView(_ selectedItem: Location) -> some View {
        ScrollView {
            LazyVStack {
                ForEach(Location.allCases, id: \.self) { item in
                    VStack {
                        Button(action: {
                            self.selectedItem = item
                            tradeViewModel.selectedLocation = item
                            myPageViewModel.tempUserFavoriteLocation = item
                            isShowingMenuList.toggle()
                        }, label: {
                            Text(item.description)
                                .font(ANBDFont.body1)
                                .foregroundStyle(Color.gray900)
                                .padding(.vertical, 5)
                                .frame(width: 100)
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
                    .fill(Color(uiColor: .systemBackground))
                    .stroke(Color.gray100, lineWidth: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .systemBackground))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray100, lineWidth: 1)
                    }
            }
        }
        .shadow(radius: 10)
    }
}

extension LocationPickerMenu {
    private func downKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LocationPickerMenu(isShowingMenuList: .constant(false), selectedItem: .constant(.seoul))
}
