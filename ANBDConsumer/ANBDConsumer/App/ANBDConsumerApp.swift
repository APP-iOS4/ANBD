//
//  ANBDConsumerApp.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
//import GoogleSignIn
import ANBDModel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//        return GIDSignIn.sharedInstance.handle(url)
//    }
}

@main
struct ANBDConsumerApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var tradeViewModel = TradeViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ANBDTabView()
        }
        .environmentObject(homeViewModel)
        .environmentObject(tradeViewModel)
        .environmentObject(myPageViewModel)
    }
}
