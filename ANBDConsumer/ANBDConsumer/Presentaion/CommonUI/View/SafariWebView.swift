//
//  SafariWebView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/5/24.
//

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}

#Preview {
    SafariWebView(url: URL(string: "https://naver.com")!)
}
