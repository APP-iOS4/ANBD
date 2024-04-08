//
//  PickerMenu.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct LocationPickerMenu: View {
    @State private var isShowingMenuList = false
    @Binding var selectedItem: Location
    
    var body: some View {
        Button(action: {
            withAnimation {
                isShowingMenuList.toggle()
            }
        }, label: {
            HStack {
                Text("\(selectedItem.description)")
                    .font(ANBDFont.SubTitle1)
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
        
        .overlay(alignment: .topLeading) {
            VStack {
                if isShowingMenuList {
                    Spacer(minLength: 50)
                    
                    LocationPickerMenuList(selectedItem: $selectedItem) { item in
                        selectedItem = item
                        withAnimation {
                            isShowingMenuList = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LocationPickerMenu(selectedItem: .constant(.seoul))
}
