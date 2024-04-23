//
//  ReportedListDetailView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/22/24.
//

import SwiftUI
import ANBDModel
import FirebaseStorage

struct ReportListDetailView: View {
    @Environment(\.presentationMode) var reportPresentationMode
    let report: Report
    let reportUsecase = DefaultReportUsecase()
    @Binding var deletedReportID: String?
    @State private var reportDeleteShowingAlert = false
    
    var body: some View {
        List {
            HStack {
                Text("신고함 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(report.id)")
            }
            HStack {
                Text("신고당한 오브젝트의 타입:").foregroundColor(.gray)
                Spacer()
                Text(" \(report.type)")
            }
            HStack {
                Text("신고당한 오브젝트 ID:").foregroundColor(.gray)
                Spacer()
                Text(" \(report.reportedObjectID)")
            }
            if report.reportedChannelID != nil{
                HStack {
                    Text("신고당한 채널 ID:").foregroundColor(.gray)
                    Spacer()
                    Text(" \(String(describing: report.reportedChannelID))")
                }
            }
            HStack {
                Text("신고 사유:").foregroundColor(.gray)
                Spacer()
                Text(" \(report.reportReason)")
            }
            HStack {
                Text("신고 받은 유저:").foregroundColor(.gray)
                Spacer()
                Text(" \(report.reportedUser)")
            }
            HStack {
                Text("생성일자:").foregroundColor(.gray)
                Spacer()
                Text(" \(dateFormatter(report.createDate))")
            }
        }
        .navigationBarTitle("신고 내역")
        .toolbar {
            Button("삭제") {
                reportDeleteShowingAlert = true // 경고를 표시
            }
        }
        .alert(isPresented: $reportDeleteShowingAlert) { // 경고를 표시
            Alert(
                title: Text("삭제"),
                message: Text("해당 신고 메세지를 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    Task {
                        do {
                            try await reportUsecase.removeReport(reportID: report.id)
                            deletedReportID = report.id
                            reportPresentationMode.wrappedValue.dismiss()
                        } catch {
                            print("신고 메세지를 삭제하는데 실패했습니다: \(error)")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        
    }
}
