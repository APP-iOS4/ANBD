//
//  SearchView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct SearchView: View {
    var category: ANBDCategory = .accua
    @State private var searchText: String = ""
    @State private var isGoingToSearchResultView: Bool = false
    
    var body: some View {
        VStack {
            
        }
        .navigationTitle("검색하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            if !searchText.isEmpty {
                isGoingToSearchResultView.toggle()
            }
        }
        .navigationDestination(isPresented: $isGoingToSearchResultView) {
            SearchResultView(category: category, searchText: searchText)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(category: .accua)
    }
}
