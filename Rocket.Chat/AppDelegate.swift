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
        return true
    }
}

