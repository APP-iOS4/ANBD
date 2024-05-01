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
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }

        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("==== willPresent ====")
        print(userInfo)
        return [[.banner, .badge, .sound]]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("==== didReceive ====")
        print(userInfo)
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
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
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                AuthenticationView()
                    .environmentObject(homeViewModel)
                    .environmentObject(tradeViewModel)
                    .environmentObject(myPageViewModel)
                    .environmentObject(articleViewModel)
                    .environmentObject(authenticationViewModel)
                    .environmentObject(searchViewModel)
                    .environmentObject(reportViewModel)
                    .environmentObject(networkMonitor)
                
                if !networkMonitor.isConnected {
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width, height: 50)
                        .foregroundStyle(.gray50)
                        .shadow(radius: 10)
                        .overlay(
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.heartRed)
                                    .padding(.trailing, 10)
                                Text("인터넷이 연결되지 않았습니다.")
                                    .font(ANBDFont.body2)
                                    .foregroundStyle(.gray900)
                            }
                        )
                }
            }
        }
    }
}

