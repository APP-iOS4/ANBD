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
    @StateObject private var chatViewModel = ChatViewModel()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // 앱이 비활성 상태로 전환될 때 수행할 작업
        chatViewModel.resetChannelListener()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 앱이 백그라운드로 이동될 때 수행할 작업
        print("백그라운드 간다")
        chatViewModel.resetChannelListener()
        print("백그라운드 갔다")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // 앱이 종료되기 전에 수행할 작업
        chatViewModel.resetChannelListener()
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
    @StateObject private var articleViewModel = ArticleViewModel()
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var reportViewModel = ReportViewModel()
    @StateObject private var coordinator = Coordinator()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            // ANBDTabView()
            AuthenticationView()
                .environmentObject(homeViewModel)
                .environmentObject(tradeViewModel)
                .environmentObject(myPageViewModel)
                .environmentObject(articleViewModel)
                .environmentObject(authenticationViewModel)
                .environmentObject(searchViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(reportViewModel)
                .environmentObject(coordinator)
        }
    }
}
