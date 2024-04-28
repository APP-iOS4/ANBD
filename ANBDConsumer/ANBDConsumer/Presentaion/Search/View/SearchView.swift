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
    
    @EnvironmentObject private var coordinator: Coordinator
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("최근 검색")
                    .font(ANBDFont.SubTitle2)
                    .foregroundStyle(.gray900)
                
                Spacer()
                
                if !searchViewModel.recentSearch.isEmpty {
                    Button(action: {
                        searchViewModel.resetRecentSearch()
                        searchViewModel.loadRecentSearch()
                    }, label: {
                        Text("전체 삭제")
                            .font(ANBDFont.body1)
                            .foregroundStyle(Color.accentColor)
                    })
                }
            }
            .padding()
            .padding(.top, 10)
            
            ForEach(searchViewModel.recentSearch, id: \.self) { recent in
                Button(action: {
                    coordinator.searchText = recent
                    coordinator.appendPath(.searchResultView)
                    
                    searchViewModel.removeRecentSearch(recent)
                    searchViewModel.saveRecentSearch(recent)
                    searchViewModel.loadRecentSearch()
                }, label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.gray400)
                            .padding(.trailing, 5)
                        
                        Text(recent)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray400)
                            .font(.system(size: 13))
                            .onTapGesture {
                                searchViewModel.removeRecentSearch(recent)
                                searchViewModel.loadRecentSearch()
                            }
                    }
                    .font(ANBDFont.body1)
                    .foregroundStyle(.gray900)
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                })
            }
            
            Spacer()
        }
        .navigationTitle("검색하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            if !searchText.isEmpty {
                searchViewModel.saveRecentSearch(searchText)
                searchViewModel.loadRecentSearch()
                
                coordinator.searchText = searchText
                coordinator.category = category
                coordinator.appendPath(.searchResultView)
                
                searchText = ""
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(category: .accua)
            .environmentObject(Coordinator())
            .environmentObject(SearchViewModel())
    }
}
