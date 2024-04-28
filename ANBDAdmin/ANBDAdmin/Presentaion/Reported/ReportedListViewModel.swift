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
    @Published var canLoadMoreReports: Bool = true
    
    func firstLoadReports() {
        for reportType in ReportType.allCases {
            Task {
                do {
                    let reports = try await reportUsecase.loadReport(reportType: reportType)
                    DispatchQueue.main.async {
                        self.reportList.append(contentsOf: reports)
                        self.canLoadMoreReports = true
                    }
                } catch {
                    print("신고 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
        /*
        func loadMoreReports() {
            guard canLoadMoreReports else { return }
            
            for reportType in ReportType.allCases {
                Task {
                    do {
                        let reports = try await reportUsecase.loadReport(reportType: reportType)
                        DispatchQueue.main.async {
                            self.reportList.append(contentsOf: reports)
                            if reports.count < 20 {
                                self.canLoadMoreReports = false
                            }
                        }
                    } catch {
                        print("신고 목록을 가져오는데 실패했습니다: \(error)")
                    }
                }
            }
        }
         */
    }
}
