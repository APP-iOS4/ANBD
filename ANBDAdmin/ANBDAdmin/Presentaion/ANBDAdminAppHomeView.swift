//
//  ContentView.swift
//  ANBDAdmin
//
//  Created by 최주리 on 4/3/24.
//
import SwiftUI

struct ANBDAdminAppHomeView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @State private var isUserListExpanded = true
    @State private var isReportedItemsExpanded = true
    @State private var isBoardListExpanded = true
    @State private var isShowingSignOutAlertView = false
    
    var body: some View {
        NavigationView {
            List {
                DisclosureGroup(isExpanded: $isUserListExpanded) {
                    NavigationLink(destination: UserListView(userLevel: .consumer).font(.title3)) {
                        Text("일반 유저")
                    }
                    NavigationLink(destination: UserListView(userLevel: .admin).font(.title3)) {
                        Text("관리자 유저")
                    }
                    NavigationLink(destination: UserListView(userLevel: .banned).font(.title3)) {
                        Text("접근 제한 유저")
                    }
                } label: {
                    Text("유저 목록").bold()
                }
                DisclosureGroup(isExpanded: $isBoardListExpanded) {
                    NavigationLink(destination: ArticleListView().font(.title3)) {
                        Text("게시글")
                    }
                    NavigationLink(destination: TradeListView().font(.title3)) {
                        Text("거래글")
                    }
                } label: {
                    Text("게시판 목록").bold()
                }
                NavigationLink(destination: ReportListView().font(.title3)) {
                    Text("신고함").bold()
                }
                NavigationLink(destination: BannerEditView().font(.title3)) {
                    Text("배너 관리").bold()
                }
                Spacer()
                Text("로그인 유저: \(UserStore.shared.user.nickname)")
                Button(action: {
                    isShowingSignOutAlertView.toggle()
                }, label: {
                    Text("로그아웃")
                        .modifier(warningTextModifier())
                })
                .buttonStyle(.bordered)
            }
            .listStyle(SidebarListStyle())
            Text("항목을 선택하세요.")
        }
        if isShowingSignOutAlertView {
            EmptyInfoView()
                .sheet(isPresented: $isShowingSignOutAlertView) {
                    CustomAlertView(isShowingCustomAlert: $isShowingSignOutAlertView, viewType: .signOut) {
                        Task {
                            try await authenticationViewModel.signOut {
                                UserDefaultsClient.shared.userInfo = nil
                                authenticationViewModel.checkAuthState()
                            }
                        }
                    }
                }
        }
    }
    fileprivate struct warningTextModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(ANBDFont.SubTitle1)
                .foregroundStyle(Color.heartRed)
                .frame(maxWidth: .infinity, minHeight: 45)
        }
    }
}
