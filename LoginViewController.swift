//
//  LoginViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/8/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Login action
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //let rootViewController = appDelegate.window!.rootViewController
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
        
        let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("leftView") as! LeftViewController
        
        let rightViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rightView") as! RightViewController
        
        let leftSideNav = UINavigationController(rootViewController: leftViewController)
        let centerNav = UINavigationController(rootViewController: centerViewController)
        let rightNav = UINavigationController(rootViewController: rightViewController)
        
        
        let centerContainer:MMDrawerController = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:rightNav)
        
        centerContainer.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView;
        centerContainer.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView;
        
        appDelegate.centerContainer = centerContainer
        
        appDelegate.window!.rootViewController = appDelegate.centerContainer
        
        appDelegate.window!.makeKeyAndVisible()
        
        
    }
    
    
    //Register a new acoount action
    @IBAction func registerNewAccountTapped(sender: AnyObject) {
    }

    
    //Forgot password action
    @IBAction func forgotPasswordTapped(sender: AnyObject) {
    }
    
    
    
    //Dismissing the keyboard
    @IBAction func dismissKeyboard(sender: AnyObject) {
        
        self.resignFirstResponder()
    }
    
    //Dismissing the keyboard when user taps outside
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    
    }
    
    
    
}
