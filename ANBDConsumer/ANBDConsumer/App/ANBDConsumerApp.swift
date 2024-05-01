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
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
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
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        
        // aps 딕셔너리에서 alert 딕셔너리 추출
        guard let apsDict = userInfo["aps"] as? [String: Any],
              let alertDict = apsDict["alert"] as? [String: String], let channelID = userInfo["channelID"] as? String else {
                  completionHandler()
                  return
              }
        
        DispatchQueue.main.async {
            Coordinator.shared.selectedTab = .chat
            
            if !Coordinator.shared.chatPath.isEmpty {
                Coordinator.shared.pop()
            }
            
            Coordinator.shared.channelID = channelID
            Coordinator.shared.appendPath(.chatDetailView)
            
            print("channelID: \(channelID)")
            print("alertDict: \(alertDict)")
        }
        
        print("channelID:\(channelID)")
        print("alertDict: \(alertDict)")
        
        completionHandler()
    }
    
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
