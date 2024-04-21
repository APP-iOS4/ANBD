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
    
    var userInfo: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Keys.userInfo.id),
                  let decodedData = try? JSONDecoder().decode(User.self, from: data)
            else { return nil }
            
            return decodedData
        }
        
        set {
            guard let encodedData = try? JSONEncoder().encode(newValue)
            else { return }
            
            UserDefaults.standard.setValue(encodedData, forKey: Keys.userInfo.id)
        }
    }
    
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
    
    enum Keys: CaseIterable {
        case userInfo
        case userID
        
        var id: String {
            "\(self)"
        }
    }
}
