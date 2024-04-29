//
//  Bundle+Extension.swift
//  ANBDConsumer
//
//  Created by 정운관 on 4/29/24.
//

import Foundation


extension Bundle {
    var firebaseServerKey: String? {
        return infoDictionary?["FirebaseServerKEY"] as? String
    }
}
