//
//  UserLevel.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum UserLevel: Int, Codable {
    case banned = 0
    case consumer = 1
    case admin = 2
}
