//
//  AppDelegate.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/5/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Launcher().prepareToLaunch(with: launchOptions)
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: AppDelegate LifeCycle
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if let _ = AuthManager.isAuthenticated() {
            UserManager.setUserPresence(status: .away) { (response) in
                SocketManager.disconnect({ (_, _) in })
            }
        }
    }
    
    // MARK: Remote Notification
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UserDefaults.standard.set(deviceToken.hexString, forKey: PushManager.kDeviceTokenKey)
    }
}
