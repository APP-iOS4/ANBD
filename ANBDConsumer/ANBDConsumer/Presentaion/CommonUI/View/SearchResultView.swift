//
//  SearchResultView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SearchResultView: View {
    var searchText: String
    @State private  var category: ANBDCategory = .accua
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 40)
                .padding()
            
            TabView(selection: $category) {
                ArticleListView(category: .accua)
                    .tag(ANBDCategory.accua)
                
                TradeListView(category: .nanua)
                    .tag(ANBDCategory.nanua)
                
                TradeListView(category: .baccua)
                    .tag(ANBDCategory.baccua)
                
                ArticleListView(category: .dasi)
                    .tag(ANBDCategory.dasi)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(searchText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        SearchResultView(searchText: "헤드셋")
            .environmentObject(ArticleViewModel())
            .environmentObject(TradeViewModel())
    }
}
