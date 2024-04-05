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
                //ADView()
                    //.environmentObject(adViewModel)
            }
            .tabItem {
                Label("정보 공유", systemImage: "leaf")
            }
            
            NavigationStack {
                //NBView()
            }
            .tabItem {
                Label("나눔·거래", systemImage: "arrow.3.trianglepath")
            }
            
            NavigationStack {
                //ChatView()
            }
            .tabItem {
                Label("채팅", systemImage: "bubble.right")
            }
            
            NavigationStack {
                //MypageView()
            }
            .tabItem {
                Label("내 정보", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    ANBDTabView()
}
