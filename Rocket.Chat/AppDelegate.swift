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
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

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
            WindowManager.open(.chat)
        } else {
            WindowManager.open(.auth(serverUrl: "", credentials: nil))
        }

        return true
    }

    // MARK: AppDelegate LifeCycle

    func applicationDidBecomeActive(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SubscriptionManager.updateUnreadApplicationBadge()

        if AuthManager.isAuthenticated() != nil {
            UserManager.setUserPresence(status: .away) { (_) in
                SocketManager.disconnect({ (_, _) in })
            }
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if AppManager.handleDeepLink(url) != nil {
            return true
        }

        return GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
    }

    // MARK: Remote Notification

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.group.set(deviceToken.hexString, forKey: PushManager.kDeviceTokenKey)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.debug("Fail to register for notification: \(error)")
    }
}
