//
//  AppDelegate.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/5/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Launcher().prepareToLaunch(with: launchOptions)

        PushManager.setupNotificationCenter()
        application.registerForRemoteNotifications()
        if let launchOptions = launchOptions,
           let notification = launchOptions[.remoteNotification] as? [AnyHashable: Any] {
            PushManager.handleNotification(raw: notification)
        }

        // If user is authenticated, open the chat right away
        // but if not, just open the authentication screen.
        if let auth = AuthManager.isAuthenticated() {
            AuthManager.persistAuthInformation(auth)
            AuthSettingsManager.shared.updateCachedSettings()
            WindowManager.open(.subscriptions)

            if let user = auth.user {
                BugTrackingCoordinator.identifyCrashReports(withUser: user)
            }
        } else {
            WindowManager.open(.auth(serverUrl: "", credentials: nil))
        }

        initNotificationWindow()

        return true
    }

    func initNotificationWindow() {
        notificationWindow = TransparentToTouchesWindow(frame: UIScreen.main.bounds)
        notificationWindow?.rootViewController = NotificationViewController.shared
        notificationWindow?.windowLevel = UIWindowLevelAlert
        notificationWindow?.makeKeyAndVisible()
    }

    // MARK: AppDelegate LifeCycle

    func applicationDidBecomeActive(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()

        if AuthManager.isAuthenticated() != nil {
            if !SocketManager.isConnected() {
                SocketManager.reconnect()
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SubscriptionManager.updateUnreadApplicationBadge()

        if AuthManager.isAuthenticated() != nil {
            UserManager.setUserPresence(status: .away) { (_) in
                SocketManager.disconnect({ (_, _) in })
            }
        }
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL, AppManager.handleDeepLink(url) != nil {
            return true
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if AppManager.handleDeepLink(url) != nil {
            return true
        }

        return false
    }

    // MARK: Remote Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.group.set(deviceToken.hexString, forKey: PushManager.kDeviceTokenKey)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("Fail to register for notification: \(error)")
    }
}
