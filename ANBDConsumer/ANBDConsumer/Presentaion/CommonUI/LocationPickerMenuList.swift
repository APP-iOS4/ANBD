//
//  PickerMenuList.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/7/24.
//

import SwiftUI
import ANBDModel

enum TestLocation: String, CaseIterable {
    case seoul
    case gyeonggi
    case incheon
    case gwangju
    case busan
    case dague
    case daejeon
    case ulsan
    case gangwon
    case gyeongBuk
    case gyeongNam
    case jeonBuk
    case jeonNam
    case chungBuk
    case chungNam
    case sejong
    case jeju
}

struct LocationPickerMenuList: View {
    @Binding var selectedItem: TestLocation
    
    let sendAction: (_ item: TestLocation) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(TestLocation.allCases, id: \.self) { item in
                    VStack {
                        Button(action: {
                            sendAction(item)
                        }, label: {
                            Text(item.rawValue)
                                .font(ANBDFont.body1)
                                .foregroundStyle(Color.gray900)
                                .padding(.vertical, 5)
                                .frame(width: 150)
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
