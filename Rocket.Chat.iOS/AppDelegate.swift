//
//  AppDelegate.swift
//  MMDrawerController
//
//  Created by Kornelakis Michael on 8/6/15.
//  Copyright © 2015 komic. All rights reserved.
//

import UIKit
import MMDrawerController
import ObjectiveDDP


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Variable to keep the MMDrawerController instance
    var centerContainer : MMDrawerController?
    
    //    var meteorClient = initialiseMeteor("pre2", "ws://localhost:4000/websocket");
    var meteorClient = initialiseMeteor("pre2", "https://demo.rocket.chat/websocket");
    
    
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), nil, displayStatusChanged, "com.apple.springboard.lockcomplete", nil, CFNotificationSuspensionBehavior.DeliverImmediately)
        
        //Subsribe to Collections
        self.meteorClient.addSubscription("activeUsers")
        //        self.meteorClient.addSubscription("userData")
        self.meteorClient.addSubscription("subscription")
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let observingOption = NSKeyValueObservingOptions.New
        meteorClient.addObserver(self, forKeyPath:"websocketReady", options: observingOption, context:nil)
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnectionReady", name: MeteorClientConnectionReadyNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name:MeteorClientDidDisconnectNotification, object: nil)
        
        return true
    }

    
    
    
    func applicationDidBecomeActive(application: UIApplication) {


        if let previousStatus = NSUserDefaults.standardUserDefaults().valueForKey("previousStatus") as? String {

            if previousStatus == "away" {
                
                //Do nothing
            
            } else {
                
                
                self.restorePreviousStatus(previousStatus)

                
            }

            
        }
        
    }
    

    
    func applicationDidEnterBackground(application: UIApplication) {
        
        let state:UIApplicationState = UIApplication.sharedApplication().applicationState
        
        if (state == UIApplicationState.Inactive) {
            
            print("Sent to background by locking screen")
            
        } else if (state == UIApplicationState.Background) {
        
            if(!NSUserDefaults.standardUserDefaults().boolForKey("kDisplayStatusLocked")){
                
                print("Sent to background by home button/switching to other app")
            
            } else {
                print("Sent to background by locking screen")
                
                //Closing the left view to remove the observer "userChange" because it interferes with restoring the status.
                //If we don't close it then when setting the status to offline because we locked the device, the app get's notified 
                //by this observer and the previousStatus(NSUserDefaults)  value is alway set to offline
                centerContainer?.closeDrawerAnimated(false, completion: nil)
                
                self.restorePreviousStatus("away")
                
            }
            
        }
    
    }
    
    
    func applicationWillEnterForeground(application: UIApplication) {

        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "kDisplayStatusLocked")
        
    }
    
    
    func restorePreviousStatus(previousStatus: String) {
        
        
        self.meteorClient.callMethodName("UserPresence:setDefaultStatus", parameters: [previousStatus], responseCallback: { (response, error) -> Void in
            
            if error != nil{
                print("Error: \(error.description)")
                return
            }
            
            //                    print(response["result"])
        })
        
        
    }
    
    
    // MARK: - connection
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<(Void)>) {
        
        if (keyPath == "websocketReady" && meteorClient.websocketReady) {
            //      connectionStatusText.text = "Connected to Todo Server"
            //      var image:UIImage = UIImage(named: "green_light.png")!
            //      connectionStatusLight.image = image
            print("connected to server!!!")
            
        }
    }
    
    
    func reportConnectionReady() {
        
        print("Connection Ready\n")
        connectWithSessionToken()
        
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("kDisplayStatusLocked")){
            print("Sent to background by home button/switching to other app")
        } else {
            if let previousStatus = NSUserDefaults.standardUserDefaults().valueForKey("previousStatus") as? String {
                print(previousStatus)
                self.meteorClient.callMethodName("UserPresence:setDefaultStatus", parameters: [previousStatus], responseCallback: { (response, error) -> Void in
                    
                    if error != nil{
                        print("Error: \(error.description)")
                        return
                    }
                    
                    //                    print(response["result"])
                })
                
            }
            
        }
        
    }
    
    
    
    func reportConnection() {
        print("================> connected to server!")
        
        //Notify current rootview controller
        let controller = self.window?.rootViewController
        
        if let controllerType = controller as? LoginViewController {
            
            controllerType.connectionStatus(true)
            
        } else if let controllerType = controller as? MMDrawerController {
            
            let centerContainerNavController = controllerType.centerViewController as! UINavigationController
            
            if let centerContainerOfMMDC = centerContainerNavController.viewControllers[0] as? ViewController {
                
                centerContainerOfMMDC.connectionStatus(true)
                
            }
        }
    }
    
    
    
    func reportDisconnection() {
        print("================> disconnected from server!")
        
        //notify current rootview controller
        let controller = self.window?.rootViewController
        
        if let controllerType = controller as? LoginViewController {
            
            controllerType.connectionStatus(false)
            
        } else if let controllerType = controller as? MMDrawerController {
            
            let centerContainerNavController = controllerType.centerViewController as! UINavigationController
            
            if let centerContainerOfMMDC = centerContainerNavController.viewControllers[0] as? ViewController {
                
                centerContainerOfMMDC.connectionStatus(false)
                
            }
        }
        
    }

    
    
    func connectWithSessionToken() {
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let sessionToken = defaults.stringForKey("sessionToken") {
            print("sessionToken: \(sessionToken)")
            
            
            
            meteorClient.logonWithSessionToken(sessionToken, responseCallback: {(response, error) -> Void in
                
                if((error) != nil) {
                    
                    print("error!!! \(error)")
                    return
                    
                }
                print("\(response)\n")
                
                let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                
                //Create and store the center the left and the right views and keep them in variables
                
                //center view
                let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
                
                //left view
                let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("leftView") as! LeftViewController
                
                //right view
                let rightViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rightView") as! RightViewController
                
                
                //Set the left, right and center views as the rootviewcontroller for the navigation controller (one rootviewcontroller at a time)
                
                let leftSideNav = UINavigationController(rootViewController: leftViewController)
                leftSideNav.setNavigationBarHidden(true, animated: false)
                let centerNav = UINavigationController(rootViewController: centerViewController)
                let rightNav = UINavigationController(rootViewController: rightViewController)
                
                //Create the MMDrawerController and keep it in a variable named center container
                let centerContainer:MMDrawerController = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:rightNav)
                
                //Open and Close gestures for the center container
                
                centerContainer.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView;
                centerContainer.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView;
                
                //Setting the width of th right view
                //centerContainer.setMaximumRightDrawerWidth(appDelegate.window!.frame.width, animated: true, completion: nil)
                
                //Set the centerContainer in the appDelegate.swift as the center container
                appDelegate.centerContainer = centerContainer
                
                //Set the rootViewController as the center container
                appDelegate.window!.rootViewController = appDelegate.centerContainer
                appDelegate.window!.makeKeyAndVisible()
            })
            
            
        }
        
        
    }
    
    
    
}
