//
//  ReportedListViewModel.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import Foundation
import ANBDModel

class ReportListViewModel: ObservableObject {
    @Published var reportList: [Report] = []
    var deletedReportID: String? // 삭제 변수
    let reportUsecase = DefaultReportUsecase()
    
    func firstLoadReports() {
        if reportList.isEmpty {
           for reportType in ReportType.allCases {
                Task {
                    do {
                        let reports = try await reportUsecase.loadReport(reportType: reportType)
                        DispatchQueue.main.async {
                            self.reportList.append(contentsOf: reports)
                        }
                    } catch {
                        print("신고 목록을 가져오는데 실패했습니다: \(error)")
                    }
                }
            }
        }
    }
}
