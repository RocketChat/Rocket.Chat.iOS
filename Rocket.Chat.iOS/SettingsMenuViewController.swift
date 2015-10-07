//

//  SettingsMenuViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 9/13/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class SettingsMenuViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Settings Menu Options

    @IBAction func preferences(sender: AnyObject) {
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let mySettingsVC = storyboard?.instantiateViewControllerWithIdentifier("mySettings")
        
        //Set it as rootViewController in the navigation controller
        let centerNewNav = UINavigationController(rootViewController: mySettingsVC!)
        
        //Set the settings controller as the center view controller in the MMDrawer
        appDel.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
        
        
        appDel.centerContainer?.closeDrawerAnimated(true, completion: nil)
        
        
    
    }
    
    
    
    @IBAction func profile(sender: AnyObject) {
    
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let profileVC = storyboard?.instantiateViewControllerWithIdentifier("profileVC") as! profileViewController
        

        
        //Set it as rootViewController in the navigation controller
        let centerNewNav = UINavigationController(rootViewController: profileVC)
        
        //Set the settings controller as the center view controller in the MMDrawer
        appDel.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
        
        appDel.centerContainer?.closeDrawerAnimated(true, completion: nil)
        
    }
    
    
    @IBAction func changeAvatar(sender: AnyObject) {
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let changeAvatarVC = storyboard?.instantiateViewControllerWithIdentifier("changeAvatar")
        
        //Set it as rootViewController in the navigation controller
        let centerNewNav = UINavigationController(rootViewController: changeAvatarVC!)
        
        //Set the settings controller as the center view controller in the MMDrawer
        appDel.centerContainer?.setCenterViewController(centerNewNav, withCloseAnimation: false, completion: nil)
        
        appDel.centerContainer?.closeDrawerAnimated(true, completion: nil)
        
    }
}
