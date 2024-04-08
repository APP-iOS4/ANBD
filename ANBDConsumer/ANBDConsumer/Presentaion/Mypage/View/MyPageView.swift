//
//  MypageView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var myPageViewModel = MyPageViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            UserInfoView()
            
            UserActivityInformationView()
            
            OtherSettingsView()
            
            Spacer()
        }
        .environmentObject(myPageViewModel)
    }
}

#Preview {
    NavigationStack {
        MyPageView()
    }
}
