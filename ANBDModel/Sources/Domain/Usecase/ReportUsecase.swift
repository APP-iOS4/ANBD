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
    func loadReport(reportType: ReportType , limit: Int) async throws -> [Report]
    func loadReport(limit: Int) async throws -> [Report]
    func removeReport(reportID : String) async throws
    func countReports() async throws -> Int
}

@available(iOS 15, *)
public struct DefaultReportUsecase: ReportUsecase {
    
    public init() {}
    
    private let reportRepository: ReportRepository = DefaultReportRepository()
    
    public func submitReport(report: Report) async throws {
        try await reportRepository.createReport(report: report)
    }
    
    //타입별
    public func loadReport(reportType: ReportType , limit: Int) async throws -> [Report] {
        try await reportRepository.readReport(reportType: reportType, limit: limit)
    }
    
    //전체
    public func resetAndLoadReport(limit: Int) async throws -> [Report] {
            try await reportRepository.resetAndReadReport(limit: limit)
        }
    
    public func loadReport(limit: Int) async throws -> [Report] {
        try await reportRepository.readReport(limit: limit)
    }
    
    public func removeReport(reportID: String) async throws {
        try await reportRepository.deleteReport(reportID: reportID)
    }
    //Count
    public func countReports() async throws -> Int {
            try await reportRepository.countReports()
        }
}
