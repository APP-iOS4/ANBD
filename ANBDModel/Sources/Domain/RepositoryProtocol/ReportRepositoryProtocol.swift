//
//  File.swift
//  
//
//  Created by 정운관 on 4/20/24.
//

import Foundation

@available(iOS 15, *)
public protocol ReportRepository {
    func createReport(report: Report) async throws
    func readReport(reportType: ReportType) async throws -> [Report]
    func deleteReport(reportID : String) async throws
}
