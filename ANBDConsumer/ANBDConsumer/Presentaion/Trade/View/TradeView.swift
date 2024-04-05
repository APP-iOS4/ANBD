//
//  TradeView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct TradeView: View {
    @State var category: Category = .nanua
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                CategoryDividerView(category: $category)
                
                TabView(selection: $category) {
                    listView
                    listView
                }
            }//VStack
            
            Button(action: {
                
            }, label: {
                WriteButtonView()
            })
        }//ZStack
        .navigationTitle("나눔 · 거래")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

extension TradeView {
    var listView: some View {
        ScrollView {
            LazyVStack {
//                ForEach() { item in
//                    NavigationLink(value: )
//                }
            }
        }
    }
    
}


#Preview {
    TradeView(category: .nanua)
}
