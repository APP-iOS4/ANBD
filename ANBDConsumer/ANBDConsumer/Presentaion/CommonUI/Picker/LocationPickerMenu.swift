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
    @State var selectedItem: Location = .seoul
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Button(action: {
                    withAnimation {
                        isShowingMenuList.toggle()
                    }
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
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .stroke(Color.gray100, lineWidth: 1)
        }
        .shadow(radius: 10)
    }
}

#Preview {
    LocationPickerMenu(isShowingMenuList: .constant(false), selectedItem: .seoul)
}
