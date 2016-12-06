//
//  AppDelegate.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/5/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import RealmSwift
import Bugsnag

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            
            if let bugsnag = keys?["Bugsnag"] as? String {
                Bugsnag.start(withApiKey: bugsnag)
            }
        }
        
        Fabric.with([Crashlytics.self])
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            deleteRealmIfMigrationNeeded: true
        )
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // We just want to reconnect if user is already in the chat
        if let _ = ChatViewController.sharedInstance() {
            if !SocketManager.isConnected() {
                SocketManager.reconnect()
            }
        }
    }

}

