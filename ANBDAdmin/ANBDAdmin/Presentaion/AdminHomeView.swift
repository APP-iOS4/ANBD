//
//  ContentView.swift
//  ANBDAdmin
//
//  Created by 최주리 on 4/3/24.
//
import SwiftUI

struct AdminHomeView: View {
    @State private var isUserListExpanded = true
    @State private var isReportedItemsExpanded = true
    @State private var isBoardListExpanded = true
    
    var body: some View {
        NavigationView {
            List {
                DisclosureGroup(isExpanded: $isUserListExpanded) {
                    NavigationLink(destination: ConsumerUserListView().font(.title3)) {
                        Text("일반 유저")
                    }
                    NavigationLink(destination: AdminUserListView().font(.title3)) {
                        Text("관리자 유저")
                    }
                } label: {
                    Text("유저 목록").bold()
                }
                DisclosureGroup(isExpanded: $isReportedItemsExpanded) {
                    NavigationLink(destination: ReportedArticleListView().font(.title3)) {
                        Text("신고된 게시물")
                    }
                    NavigationLink(destination: ReportedCommentListView().font(.title3)) {
                        Text("신고된 댓글")
                    }
                } label: {
                    Text("신고된 작성물").bold()
                }
                DisclosureGroup(isExpanded: $isBoardListExpanded) {
                    NavigationLink(destination: ArticleListView().font(.title3)) {
                        Text("게시물")
                    }
                    NavigationLink(destination: TradeListView().font(.title3)) {
                        Text("거래글")
                    }
                } label: {
                    Text("게시판 목록").bold()
                }
                NavigationLink(destination: BannerEditView().font(.title3)) {
                    Text("배너 관리").bold()
                }
            }
            .listStyle(SidebarListStyle())
            
            Text("항목을 선택하세요.")
        }
    }
}
