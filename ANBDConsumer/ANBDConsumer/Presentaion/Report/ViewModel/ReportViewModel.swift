//
//  ReportViewModel.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/20/24.
//

import Foundation
import ANBDModel

final class ReportViewModel: ObservableObject {
    private let reportUsecase: ReportUsecase = DefaultReportUsecase()
    
    @Published var user: User?
    
    /// 유저 정보 불러오기
    func loadUserInfo() {
        if let user = UserDefaultsClient.shared.userInfo {
            self.user = user
        }
    }
    
    /// 신고하기
    func submitReport(reportType: ReportType, reportReason: String, reportedObjectID: String, reportChannelID: String?) async throws {
        do {
            if let user {
                let report = Report(type: reportType, reportReason: reportReason, reportedUser: user.id, reportedObjectID: reportedObjectID, reportedChannelID: reportChannelID)
                try await reportUsecase.submitReport(report: report)
            }
        } catch {
            print("submitReport ERROR: \(error)")
        }
    }
}
