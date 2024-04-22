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
    func loadReport(reportType: ReportType) async throws -> [Report]
    func removeReport(reportID : String) async throws
}

@available(iOS 15, *)
public struct DefaultReportUsecase: ReportUsecase {
    
    public init() {}
    
    private let reportRepository: ReportRepository = DefaultReportRepository()
    
    public func submitReport(report: Report) async throws {
        try await reportRepository.createReport(report: report)
    }
    
    public func loadReport(reportType: ReportType) async throws -> [Report] {
        try await reportRepository.readReport(reportType: reportType)
    }
    
    public func removeReport(reportID: String) async throws {
        try await reportRepository.deleteReport(reportID: reportID)
    }
    
    
}
