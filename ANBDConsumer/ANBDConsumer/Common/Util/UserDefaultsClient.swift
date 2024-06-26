//
//  UserDefaultsClient.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/16/24.
//

import Foundation
import ANBDModel

final class UserDefaultsClient: ObservableObject {
    static let shared = UserDefaultsClient()
    
    init() { }
    
    var userID: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.userID.id)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userID.id)
        }
    }
    
    func removeUserID() {
        UserDefaults.standard.removeObject(forKey: Keys.userID.id)
    }
    
    var recentSearch: [String] {
        get {
            UserDefaults.standard.array(forKey: Keys.recentSearch.id) as? [String] ?? []
        }
    }
    
    func saveRecentSearch(_ searchText: String) {
        var searchArray: [String] = recentSearch
        
        if searchArray.contains(searchText) {
            if let idx = searchArray.firstIndex(of: searchText) {
                searchArray.remove(at: idx)
            }
        }
    
        if searchArray.count > 7 {
            searchArray.remove(at: 0)
        }
        
        searchArray.append(searchText)
        UserDefaults.standard.set(searchArray, forKey: Keys.recentSearch.id)
    }
    
    func removeRecentSearch(_ searchText: String) {
        var searchArray: [String] = recentSearch
        
        if let idx = searchArray.firstIndex(of: searchText) {
            searchArray.remove(at: idx)
        }
        UserDefaults.standard.set(searchArray, forKey: Keys.recentSearch.id)
    }
    
    func resetRecentSearch() {
        UserDefaults.standard.set([], forKey: Keys.recentSearch.id)
    }
    
    enum Keys: CaseIterable {
        case userInfo
        case userID
        case recentSearch
        
        var id: String {
            "\(self)"
        }
    }
}
