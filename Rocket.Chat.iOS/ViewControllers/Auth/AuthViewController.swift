//
//  AuthViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 9/25/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController

class AuthViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  func getTokenAndSaveUser(email: String, response: NSDictionary) -> Bool {
    let res = response["result"] as? NSDictionary
    if (res == nil){
      return false
    }
    let serverSessionToken = res!["token"] as? String
    let userId = res!["id"] as? String
    if (serverSessionToken == nil || userId == nil){
      return false
    }
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(serverSessionToken, forKey: "sessionToken")
    defaults.setObject(email, forKey: "email")
    
    return true
  }
  
  
  func createMainMMDrawer(){
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    self.view.endEditing(true)
    
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
