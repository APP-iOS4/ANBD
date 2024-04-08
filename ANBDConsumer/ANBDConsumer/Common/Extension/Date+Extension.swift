//
//  Date+Extension.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/8/24.
//

import Foundation

extension Date {
    var relativeTimeNamed: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
