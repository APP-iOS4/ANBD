//
//  ReportedCommentListView.swift
//  ANBDAdmin
//
//  Created by sswv on 4/8/24.
//

import SwiftUI
import ANBDModel

struct ReportListView: View {
    @StateObject private var reportListViewModel = ReportListViewModel()
    @State private var selectedReportType: ReportType = .article // 기본 선택값은 '게시물'
    
    
    var body: some View {
        VStack {
            Text("신고 메세지 개수: \(reportListViewModel.reportCount)")
                .font(ANBDFont.Heading3)
                .task {
                    await reportListViewModel.fetchReportCount()
                }
            Picker("신고 유형 선택", selection: $selectedReportType) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedReportType){ newType in
                Task {
                    reportListViewModel.reportList = []
                    await reportListViewModel.firstLoadReports(of: newType)
                }
            }
            HStack{
                Spacer()
                VStack(alignment: .leading) {
                    Text("신고당한 오브젝트 타입")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("내용")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Divider()
                Spacer()
                VStack(alignment: .leading) {
                    Text("생성일자")
                        .font(.title3)
                }
                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            ScrollView{
                LazyVStack {
                    ForEach(reportListViewModel.reportList, id: \.id) { report in
                        NavigationLink(destination: ReportListDetailView(report: report, deletedReportID: $reportListViewModel.deletedReportID)) {
                            HStack{
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(report.type)")
                                        .font(.title3)
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(report.reportReason)")
                                        .lineLimit(1)
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Divider()
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("\(report.reportedDate)")
                                        .foregroundColor(Color("DefaultTextColor"))
                                }
                                .frame(minWidth: 0, maxWidth: 260, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("DefaultCellColor"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    if !reportListViewModel.reportList.isEmpty {
                        Text("List End")
                            .foregroundColor(.gray)
                            .onAppear {
                                reportListViewModel.loadMoreReports(of: selectedReportType)
                            }
                    }
                }
                .onAppear {
                    Task{
                        await reportListViewModel.firstLoadReports(of: selectedReportType)
                    }
                }
                .navigationBarTitle("신고함 목록")
                .toolbar {
                    Button(action: {
                        reportListViewModel.reportList = []
                        Task{
                            await reportListViewModel.firstLoadReports(of: selectedReportType)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding(.top, 10)
            .background(Color(.systemGroupedBackground))
        }
    }
}
