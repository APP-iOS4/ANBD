//
//  PickerMenuList.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel

struct LocationPickerMenuList: View {
    @Binding var selectedItem: Location
    
    let sendAction: (_ item: Location) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Location.allCases, id: \.self) { item in
                    VStack {
                        Button(action: {
                            sendAction(item)
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
        .frame(width: 250, height: 300)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray50)
                .stroke(Color.gray100, lineWidth: 1)
        }
        .shadow(radius: 10)
    }
}

#Preview {
    LocationPickerMenuList(selectedItem: .constant(.seoul), sendAction: { _ in})
}
