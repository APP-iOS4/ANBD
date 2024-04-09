//
//  SearchResultView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SearchResultView: View {
    @State var category: ANBDCategory = .accua
    var searchText: String
    
    var body: some View {
        VStack {
            CategoryDividerView(category: $category, isFromSearchView: true)
                .frame(height: 40)
                .padding()
            
            TabView(selection: $category) {
                ArticleListView(category: .accua, searchText: searchText)
                    .tag(ANBDCategory.accua)
                
                TradeListView(category: .nanua, searchText: searchText)
                    .tag(ANBDCategory.nanua)
                
                TradeListView(category: .baccua, searchText: searchText)
                    .tag(ANBDCategory.baccua)
                
                ArticleListView(category: .dasi, searchText: searchText)
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
