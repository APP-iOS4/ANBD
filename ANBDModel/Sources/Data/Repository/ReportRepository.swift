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
    private var reportDB = Firestore.firestore().collection("Report")
    
    private var nextDoc: DocumentSnapshot?
    
    func createReport(report: Report) async throws{
        guard let _ = try? reportDB.document(report.id).setData(from: report)
        else {
            throw DBError.unknownError
        }
    }
    
    func readReport() async throws -> [Report]{
        let commonQuery = reportDB
            .order(by: "createdAt" ,descending: true)
            .limit(toLast: 20)
        
        var requestQuery : Query
        
        if let nextDoc = nextDoc {
            requestQuery = commonQuery.end(beforeDocument: nextDoc)
        } else {
            requestQuery = commonQuery
        }
        
        guard let snapshot = try? await requestQuery.getDocuments() else {
            throw DBError.unknownError
        }
        
        if snapshot.documents.isEmpty {
            return []
        }
        
        nextDoc = snapshot.documents.first
        
        return snapshot.documents.compactMap {try? $0.data(as: Report.self)}
    }
    
    func deleteReport(reportID : String) async throws {
        guard let _ = try? await reportDB.document(reportID).delete() else {
            throw DBError.unknownError
        }
    }
    
}
