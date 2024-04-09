//
//  ContentView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct ANBDTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("홈", systemImage: "house")
            }
            
            NavigationStack {
                ArticleView()
            }
            .tabItem {
                Label("정보 공유", systemImage: "leaf")
            }
            
            NavigationStack {
                TradeView()
            }
            .tabItem {
                Label("나눔·거래", systemImage: "arrow.3.trianglepath")
            }
            
            NavigationStack {
                ChatView()
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.right")
            }
            
            NavigationStack {
                UserPageView(isSignedInUser: true)
            }
            .tabItem {
                Label("내 정보", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    ANBDTabView()
        .environmentObject(HomeViewModel())
        .environmentObject(TradeViewModel())
        .environmentObject(ArticleViewModel())
        .environmentObject(MyPageViewModel())
}
