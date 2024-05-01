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
    
    // Foreground(앱 켜진 상태)에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.list, .banner])
    }
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let channelID = userInfo["channelID"] as? String  {
            DispatchQueue.main.async {
                self.presentChatDeatailView(channelID: channelID)
            }
        }
        
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

extension AppDelegate {
    func presentChatDeatailView(channelID: String) {
        let coorinator = Coordinator.shared
        if !coorinator.chatPath.isEmpty {
            coorinator.pop(coorinator.chatPath.count)
            coorinator.channelID = channelID
            coorinator.selectedTab = .home
        }
        coorinator.selectedTab = .chat
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                coorinator.channelID = channelID
                coorinator.appendPath(.chatDetailView)
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
