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
        
        if let type = userInfo["type"] as? String,
           let articleID = userInfo["articleID"] as? String {
            self.presentArticleDeatailView(articleID: articleID)
        }
        
        completionHandler()
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    //    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    //        Messaging.messaging().token { token, error in
    //            if let error = error {
    //                print("Error fetching FCM registration token: \(error)")
    //            } else if let token = token {
    //                UserStore.shared.deviceToken = token
    //            }
    //        }
    //    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        if let fcmToken {
            UserStore.shared.deviceToken = fcmToken
        }
    }
}

extension AppDelegate {
    func presentChatDeatailView(channelID: String) {
        let coordinator = Coordinator.shared
        if !coordinator.chatPath.isEmpty {
            coordinator.pop(coordinator.chatPath.count)
            coordinator.channelID = channelID
            //            coordinator.selectedTab = .home
        }
        coordinator.selectedTab = .chat
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            coordinator.channelID = channelID
            coordinator.appendPath(.chatDetailView)
        }
        
    }
    
    func presentArticleDeatailView(articleID: String) {
        let coordinator = Coordinator.shared
        coordinator.article = nil
        coordinator.articleID = articleID
        coordinator.selectedTab = .article
        coordinator.pop(coordinator.articlePath.count)
        
        coordinator.appendPath(.articleDeatilView)
        
        
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
    @StateObject private var toastManager = ToastManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingBannedAlert = false
    
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
                    .environmentObject(toastManager)
                
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
                if isShowingBannedAlert {
                    CustomAlertView(isShowingCustomAlert: $isShowingBannedAlert, viewType: .userKicked) {
                    }
                }
            }
            .toastView(toast: Binding(get: { ToastManager.shared.toast },
                                      set: { ToastManager.shared.toast = $0 }))
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                if UserStore.shared.user.userLevel == .banned {
                    Task {
                        await authenticationViewModel.signOut {
                            UserDefaultsClient.shared.removeUserID()
                            UserStore.shared.user = MyPageViewModel.mockUser
                        }
                    }
                    authenticationViewModel.checkAuthState()
                    isShowingBannedAlert = true
                }
            case .inactive:
                break
            case .background:
                if authenticationViewModel.authState == true{
                    Task{
                        await UserStore.shared.getUserInfo(userID: UserStore.shared.user.id)
                    }
                }
            @unknown default:
                break
            }
        }
    }
}
