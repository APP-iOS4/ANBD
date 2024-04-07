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
        VStack {
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
