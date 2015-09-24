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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Variable to keep the MMDrawerController instance
    var centerContainer : MMDrawerController?
    private(set) var model : CoreDataModel?
    private(set) var stack : CoreDataStack?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        model = CoreDataModel(name: "Rocket_Chat_iOS")
        stack = CoreDataStack(model: model!)

        
        return true
    }
}
