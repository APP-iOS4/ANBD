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
    
    @Published var user: User = UserStore.shared.user
    
    /// 신고하기
    @MainActor
    func submitReport(reportType: ReportType, reportReason: String, reportedObjectID: String, reportChannelID: String?) async {
        do {
            guard let userID = UserDefaultsClient.shared.userID else { return }
            user = await UserStore.shared.getUserInfo(userID: userID)
            let report = Report(type: reportType, reportReason: reportReason, reportedUser: user.id, reportedObjectID: reportedObjectID, reportedChannelID: reportChannelID)
            try await reportUsecase.submitReport(report: report)
            
            ToastManager.shared.toast = Toast(style: .success, message: "신고가 접수되었습니다.")
        } catch {
            print("submitReport ERROR: \(error)")
            
            guard let error = error as? DBError else {
                ToastManager.shared.toast = Toast(style: .error, message: "알 수 없는 오류가 발생하였습니다.")
                return
            }
            ToastManager.shared.toast = Toast(style: .error, message: "\(error.message)")
        }
    }
}
