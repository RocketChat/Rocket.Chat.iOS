//
//  AppDelegate.swift
//  MMDrawerController
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 komic. All rights reserved.
//

import UIKit
import JSQCoreDataKit
import MMDrawerController
import ObjectiveDDP

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Variable to keep the MMDrawerController instance
    var centerContainer : MMDrawerController?
    private(set) var model : CoreDataModel?
    private(set) var stack : CoreDataStack?

    var meteorClient = initialiseMeteor("pre2", "ws://localhost:4000/websocket");

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        model = CoreDataModel(name: "Rocket_Chat_iOS")
        stack = CoreDataStack(model: model!)

//      let storyboard = UIStoryboard(name: "Main", bundle: nil)

//        let loginController:LoginViewController =  storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
//        loginController.meteor = self.meteorClient

//        meteorClient.addSubscription("things")
//        meteorClient.addSubscription("lists")

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name:MeteorClientDidDisconnectNotification, object: nil)

        return true
    }

        func reportConnection() {
            print("================> connected to server!")
        }

        func reportDisconnection() {
            print("================> disconnected from server!")
        }


}
