//
//  File.swift
//  
//
//  Created by 정운관 on 4/20/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

@available(iOS 15, *)
final class DefaultReportRepository: ReportRepository {
    private let reportDB = Firestore.firestore().collection("Report")
    
    private var nextDoc: DocumentSnapshot?
    private var allTypeNextDoc: DocumentSnapshot?
    
    func createReport(report: Report) async throws {
        guard let _ = try? reportDB.document(report.id).setData(from: report)
        else {
            throw DBError.setReportDocumentError
        }
    }
    
    func readReport(reportType: ReportType , limit: Int) async throws -> [Report] {
        
        let commonQuery = reportDB
            .whereField("type", isEqualTo: reportType.rawValue)
            .order(by: "createDate" ,descending: true)
            .limit(toLast: limit)
        
        var requestQuery : Query
        
        if let nextDoc = nextDoc {
            requestQuery = commonQuery.end(beforeDocument: nextDoc)
        } else {
            requestQuery = commonQuery
        }
        
        guard let snapshot = try? await requestQuery.getDocuments() else {
            throw DBError.getReportDocumentError
        }
        
        if snapshot.documents.isEmpty {
            return []
        }
        
        nextDoc = snapshot.documents.first
        
        let reportList = try snapshot.documents.compactMap { try $0.data(as: Report.self) }
        return reportList
    }
    
    func readReport(limit: Int) async throws -> [Report] {
        
        let commonQuery = reportDB
            .order(by: "createDate" ,descending: true)
            .limit(toLast: limit)
        
        var requestQuery : Query
        
        if let allTypeNextDoc = allTypeNextDoc {
            requestQuery = commonQuery.end(beforeDocument: allTypeNextDoc)
        } else {
            requestQuery = commonQuery
        }
        
        guard let snapshot = try? await requestQuery.getDocuments() else {
            throw DBError.getReportDocumentError
        }
        
        if snapshot.documents.isEmpty {
            return []
        }
        
        allTypeNextDoc = snapshot.documents.first
        
        let reportList = try snapshot.documents.compactMap { try $0.data(as: Report.self) }
        return reportList
    }
    
    func deleteReport(reportID : String) async throws {
        guard let _ = try? await reportDB.document(reportID).delete() else {
            throw DBError.deleteReportDocumentError
        }
    }
    
}
