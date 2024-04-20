//
//  File.swift
//  
//
//  Created by 정운관 on 4/20/24.
//

import Foundation

@available(iOS 15, *)
public protocol ReportUsecase {
    func submitReport(report: Report) async throws
    func loadReport() async throws -> [Report]
    func removeReport(reportID : String) async throws
}

@available(iOS 15, *)
final class DefaultReportUsecase: ReportUsecase {
    
    let reportRepository: ReportRepository = DefaultReportRepository()
    
    func submitReport(report: Report) async throws {
        try await reportRepository.createReport(report: report)
    }
    
    func loadReport() async throws -> [Report] {
        try await reportRepository.readReport()
    }
    
    func removeReport(reportID: String) async throws {
        try await reportRepository.deleteReport(reportID: reportID)
    }
    
    
}
