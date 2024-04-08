//
//  MypageView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import ANBDModel

struct UserPageView: View {
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            UserInfoView()
            
            UserActivityInfoView()
            
            OtherSettingsView()
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        UserPageView()
            .environmentObject(MyPageViewModel())
    }
}
