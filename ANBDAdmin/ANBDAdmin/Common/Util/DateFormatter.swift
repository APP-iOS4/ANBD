//
//  DateFormatter.swift
//  ANBDAdmin
//
//  Created by sswv on 4/10/24.
//

import Foundation

func dateFormatter(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(abbreviation: "KST")
    formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
    return formatter.string(from: date)
}

