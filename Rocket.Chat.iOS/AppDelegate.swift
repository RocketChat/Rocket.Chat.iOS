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
  
    var meteorClient = initialiseMeteor("pre2", "ws://localhost:4000/websocket");
//    var meteorClient = initialiseMeteor("pre2", "https://demo.rocket.chat/home");

  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    let observingOption = NSKeyValueObservingOptions.New
    meteorClient.addObserver(self, forKeyPath:"websocketReady", options: observingOption, context:nil)
    
    
    //      let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    //        let loginController:LoginViewController =  storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
    //        loginController.meteor = self.meteorClient
    
    //        meteorClient.addSubscription("things")
    //        meteorClient.addSubscription("lists")
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnectionReady", name: MeteorClientConnectionReadyNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportConnection", name: MeteorClientDidConnectNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reportDisconnection", name:MeteorClientDidDisconnectNotification, object: nil)
    
    return true
  }
  
    func reportConnectionReady() {
        
        connectWithSessionToken()
        
    }
    
  func reportConnection() {
    print("================> connected to server!")
  }
  
  func reportDisconnection() {
    print("================> disconnected from server!")
  }
  
  // MARK: - Connection
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<(Void)>) {
    
    if (keyPath == "websocketReady" && meteorClient.websocketReady) {
      //      connectionStatusText.text = "Connected to Todo Server"
      //      var image:UIImage = UIImage(named: "green_light.png")!
      //      connectionStatusLight.image = image
      print("connected to server!!!")
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
                print(response)
            })
            
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
        }
        
        
    }
    
    
    
}
