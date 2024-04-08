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
            HStack {
                LightBlueCapsuleButtonView(text: "지역 \(tradeViewModel.selectedLocations.count)")
                    .padding(.trailing, 280)
                    
                Spacer()
            }
            
            ScrollView {
                ForEach(Location.allCases, id: \.self) { item in
                    Button(action: {
                        if tradeViewModel.selectedLocations.contains(item) {
                            tradeViewModel.selectedLocations.remove(item)
                        } else {
                            tradeViewModel.selectedLocations.insert(item)
                        }
                    }, label: {
                        CheckboxView(isChecked: tradeViewModel.selectedLocations.contains(item), text: item.description)
                    })
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Button(action: {
                    tradeViewModel.selectedLocations = []
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
                    isShowingLocation.toggle()
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
    LocationBottomSheet(isShowingLocation: .constant(true))
        .environmentObject(TradeViewModel())
}
