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
import FirebaseMessaging
import ANBDModel

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
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


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.list, .banner])
//    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    UserStore.shared.deviceToken = token
                }
            }
        }
}


@main
struct ANBDConsumerApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var tradeViewModel = TradeViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    @StateObject private var articleViewModel = ArticleViewModel()
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @StateObject private var reportViewModel = ReportViewModel()
    
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
                .environmentObject(reportViewModel)
        }
    }
}
