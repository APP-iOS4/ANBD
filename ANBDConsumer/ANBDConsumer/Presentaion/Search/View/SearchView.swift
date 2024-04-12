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
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("최근 검색")
                    .font(ANBDFont.SubTitle2)
                    .foregroundStyle(.gray900)
                
                Spacer()
                
                Button(action: {
                    searchViewModel.recentSearch = []
                }, label: {
                    Text("전체 삭제")
                        .font(ANBDFont.body1)
                        .foregroundStyle(Color.accentColor)
                })
            }
            .padding()
            .padding(.top, 10)
            
            ForEach(searchViewModel.recentSearch, id: \.self) { recent in
//                NavigationLink(value: recent) {
//                    HStack {
//                        Image(systemName: "clock.arrow.circlepath")
//                            .foregroundStyle(.gray400)
//                            .padding(.trailing, 5)
//                        
//                        Text(recent)
//                        
//                        Spacer()
//                        
//                        Image(systemName: "xmark")
//                            .foregroundStyle(.gray400)
//                            .font(.system(size: 13))
//                            .onTapGesture {
//                                if let idx = searchViewModel.recentSearch.firstIndex(of: recent) {
//                                    searchViewModel.recentSearch.remove(at: idx)
//                                }
//                            }
//                    }
//                    .font(ANBDFont.body1)
//                    .foregroundStyle(.gray900)
//                    .padding(.horizontal)
//                    .padding(.vertical, 3)
//                }
//            
                
                NavigationLink {
                    SearchResultView(category: category, searchText: recent)
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.gray400)
                            .padding(.trailing, 5)

                        Text(recent)

                        Spacer()

                        Image(systemName: "xmark")
                            .foregroundStyle(.gray400)
                            .font(.system(size: 13))
                            .onTapGesture {
                                if let idx = searchViewModel.recentSearch.firstIndex(of: recent) {
                                    searchViewModel.recentSearch.remove(at: idx)
                                }
                            }
                    }
                    .font(ANBDFont.body1)
                    .foregroundStyle(.gray900)
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                }

                
//                NavigationLink(destination: SearchResultView(category: category, searchText: recent)) {
//                    HStack {
//                        Image(systemName: "clock.arrow.circlepath")
//                            .foregroundStyle(.gray400)
//                            .padding(.trailing, 5)
//                            
//                        Text(recent)
//                        
//                        Spacer()
//                        
//                        Image(systemName: "xmark")
//                            .foregroundStyle(.gray400)
//                            .font(.system(size: 13))
//                            .onTapGesture {
//                                if let idx = searchViewModel.recentSearch.firstIndex(of: recent) {
//                                    searchViewModel.recentSearch.remove(at: idx)
//                                }
//                            }
//                    }
//                    .font(ANBDFont.body1)
//                    .foregroundStyle(.gray900)
//                    .padding(.horizontal)
//                    .padding(.vertical, 3)
//                }
            }
            
            Spacer()
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
        .navigationDestination(for: String.self) { search in
            SearchResultView(category: category, searchText: search)
        }
    }
}

#Preview {
    NavigationStack {
        SearchView(category: .accua)
            .environmentObject(SearchViewModel())
    }
}
