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
    @State private var selectedCategory: ReportType = .article // Default

    var body: some View {
        VStack {
            Text("미응답 된 신고 메세지 : \(reportListViewModel.reportCount)")
                .font(ANBDFont.Heading3)
                .task {
                                await reportListViewModel.fetchReportCount()
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
                              reportListViewModel.loadMoreReports()
                          }
                      }
                }
                .onAppear {
                    reportListViewModel.firstLoadReports()
                }
                .navigationBarTitle("신고함 목록")
                .toolbar {
                    Button(action: {
                        reportListViewModel.reportList = []
                        reportListViewModel.firstLoadReports()
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
