//
//  ReportView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ReportView: View {
    
    @EnvironmentObject private var reportViewModel: ReportViewModel
    @StateObject private var coordinator = Coordinator.shared
    @Environment(\.dismiss) private var dismiss
    
    var reportViewType: ReportType = .article
    var reportedObjectID: String
    var reportedChannelID: String?
    @State private var reportReason: String = ""
    @State private var isShowingCustomAlert: Bool = false
    
    var body: some View {
        if #available(iOS 17.0, *) {
            reportView
                .onChange(of: reportReason) {
                    if reportReason.count > 200 {
                        reportReason = String(reportReason.prefix(200))
                    }
                }
        } else {
            reportView
                .onChange(of: reportReason) { report in
                    if report.count > 200 {
                        reportReason = String(report.prefix(200))
                    }
                }
        }
    }
    
    private var reportView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("\(reportTitle) 신고하기")
                    .foregroundStyle(.gray900)
                    .font(ANBDFont.SubTitle1)
                
                VStack(alignment: .trailing) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.clear)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray400))
                        
                        
                        TextEditor(text: $reportReason)
                            .foregroundStyle(.gray900)
                            .padding(13)
                        
                        
                        if reportReason.isEmpty {
                            Text("신고 내용을 입력해주세요. (최대 200자)")
                                .padding()
                                .padding(.top, 5)
                        }
                    }
                    .frame(height: 200)
                    .font(ANBDFont.body1)
                    
                    Text("\(reportReason.count)/200")
                        .padding(.horizontal, 5)
                        .font(ANBDFont.body2)
                }
                .foregroundStyle(.gray400)
                .padding(.vertical, 10)
                
                Spacer()
                
                Button(action: {
                    endTextEditing()
                    if !reportReason.isEmpty {
                        isShowingCustomAlert.toggle()
                    }
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(reportReason.isEmpty ? .gray300 : Color.accentColor)
                        
                        Text("신고하기")
                            .foregroundStyle(.white)
                    }
                })
                .disabled(reportReason.isEmpty)
                .frame(height: 50)
            }
            .padding()
            
            if isShowingCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlert, viewType: .report) {
                    Task {
                        await reportViewModel.submitReport(reportType: reportViewType, reportReason: reportReason, reportedObjectID: reportedObjectID, reportChannelID: reportedChannelID)
                        dismiss()
                        try await Task.sleep(nanoseconds: 500_000_000)
                        coordinator.isShowingToastView = true
                    }
                }
            }
        }
        .navigationTitle("신고하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarRole(.editor)
        .onTapGesture {
            endTextEditing()
        }
    }
}

extension ReportView {
    private var reportTitle: String {
        switch reportViewType {
        case .article:
            return "게시글"
        case .trade:
            return "게시물"
        case .comment:
            return "댓글"
        case .message:
            return "메시지"
        case .chatRoom:
            return "채팅"
        case .user:
            return "사용자"
        }
    }
}

#Preview {
    NavigationStack {
        ReportView(reportedObjectID: "")
            .environmentObject(ReportViewModel())
    }
}
