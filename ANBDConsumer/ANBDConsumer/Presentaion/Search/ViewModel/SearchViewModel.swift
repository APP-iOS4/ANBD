//
//  SearchViewModel.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/11/24.
//

import Foundation

final class SearchViewModel: ObservableObject {
    
    @Published var recentSearch: [String] = UserDefaultsClient.shared.recentSearch.reversed()
    
    func loadRecentSearch() {
        recentSearch = UserDefaultsClient.shared.recentSearch.reversed()
    }
    
    func saveRecentSearch(_ searchText: String) {
        UserDefaultsClient.shared.saveRecentSearch(searchText)
    }
    
    func removeRecentSearch(_ searchText: String) {
        UserDefaultsClient.shared.removeRecentSearch(searchText)
    }
    
    func resetRecentSearch() {
        UserDefaultsClient.shared.resetRecentSearch()
    }
}
