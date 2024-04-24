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
    var category: ANBDCategory
    
    @State private var tmpSelectedLocation: [Location] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CapsuleButtonView(text: "지역 \(tmpSelectedLocation.count)", buttonColor: .lightBlue, fontColor: .accent)
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing, 280)
                    
                Spacer()
            }
            
            ScrollView {
                ForEach(Location.allCases, id: \.self) { item in
                    Button(action: {
                        if tmpSelectedLocation.contains(item) {
                            if let firstIndex = tmpSelectedLocation.firstIndex(of: item) {
                                tmpSelectedLocation.remove(at: firstIndex)
                            }
                        } else {
                            tmpSelectedLocation.append(item)
                        }
                    }, label: {
                        CheckboxView(isChecked: tmpSelectedLocation.contains(item), text: item.description)
                    })
                    .padding(.vertical, 5)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            HStack {
                Button(action: {
                    tmpSelectedLocation = []
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
                    tradeViewModel.selectedLocations = tmpSelectedLocation
                    Task {
                        await tradeViewModel.reloadFilteredTrades(category:category)
                        isShowingLocation.toggle()
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
            tmpSelectedLocation = tradeViewModel.selectedLocations
        }
    }
}

//#Preview {
//    LocationBottomSheet(isShowingLocation: .constant(true))
//        .environmentObject(TradeViewModel())
//}
