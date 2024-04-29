//
//  TermsView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct TermsView: View {
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    private let type: AgreeType
    
    init(type: AgreeType) {
        self.type = type
    }
    
    var body: some View {
        SafariWebView(url: URL(string: "\(type.url)") ?? URL(string: "https://oval-second-abc.notion.site/ANBD-036716b1ef784b019ab0df8147bd4e65")!)
            .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    TermsView(type: .agreeCollectionInfo)
        .environmentObject(AuthenticationViewModel())
}
