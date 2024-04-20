//
//  File.swift
//  
//
//  Created by 정운관 on 4/20/24.
//

import Foundation

@available(iOS 15, *)
public struct Report : Identifiable, Codable , Hashable {
    
    public var id: String
    
    public let type: ReportType
    public let reportReason: String
    public let reportedUser: String

    public let reportedObjectID: String
    
    //메시진 신고일때만 하나의 reportedObjectID 더 필요함
    public let reportedChannelID: String? = nil
    
    private var createDate: Date = Date()
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 hh시 mm분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter
    }()
    
    public var reportedDate: String {
        return Report.dateFormatter.string(from: createDate)
    }
    
    public init(type: ReportType, reportReason: String, reportedUser: String , reportedObjectID: String, reportedChannelID: String? = nil) {
        self.id = UUID().uuidString
        self.type = type
        self.reportReason = reportReason
        self.reportedUser = reportedUser
        self.reportedObjectID = reportedObjectID
        self.reportedChannelID = reportedChannelID
    }
}
