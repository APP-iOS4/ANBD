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
    private let reportUsecase = DefaultReportUsecase()
    @Published var canLoadMoreReports: Bool = true
    @Published var reportCount: Int = 0
    
    func firstLoadReports() {
        if reportList.isEmpty {
            Task {
                do {
                    let reports = try await reportUsecase.resetAndLoadReport(limit: 10)
                    DispatchQueue.main.async {
                        self.reportList = reports
                        self.canLoadMoreReports = true
                    }
                } catch {
                    print("신고 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    }
    func firstLoadReports(of category: ReportType) async {
        do {
            let reports = try await reportUsecase.resetAndLoadReport(reportType: category, limit: 10)
            DispatchQueue.main.async {
                self.reportList = reports
                self.canLoadMoreReports = true
            }
        } catch {
            print("Error loading reports of type \(category.rawValue): \(error)")
        }
    }
        
        func loadMoreReports() {
            Task {
                do {
                    let reports = try await reportUsecase.loadReport(limit: 11)
                    DispatchQueue.main.async {
                        if reports.count == 11 {
                            self.reportList.append(contentsOf: reports.dropLast())
                            self.canLoadMoreReports = true
                        } else {
                            self.reportList.append(contentsOf: reports)
                            self.canLoadMoreReports = false
                        }
                    }
                } catch {
                    print("신고 목록을 가져오는데 실패했습니다: \(error)")
                }
            }
        }
    func loadMoreReports(of category: ReportType) {
        Task {
            do {
                let reports = try await reportUsecase.loadReport(reportType: category, limit: 11)
                DispatchQueue.main.async {
                    if reports.count == 11 {
                        self.reportList.append(contentsOf: reports.dropLast())
                        self.canLoadMoreReports = true
                    } else {
                        self.reportList.append(contentsOf: reports)
                        self.canLoadMoreReports = false
                    }
                }
            } catch {
                print("신고 목록을 가져오는데 실패했습니다: \(error)")
            }
        }
    }
    
    func fetchReportCount() async {
            do {
                let count = try await reportUsecase.countReports()
                DispatchQueue.main.async {
                    self.reportCount = count
                }
            } catch {
                print("Error counting reports: \(error)")
            }
        }
}
