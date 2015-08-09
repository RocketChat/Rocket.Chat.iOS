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
        
        //set password textfield to secure entry textfield
        passwordTextField.secureTextEntry = true
        
        
        //Add listener for the textinput for when input changes
        userNameTextField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        passwordTextField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Login action
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        
        //Check if username is empty
        
        if(userNameTextField.text == ""){
            
            //if empty change username textfield border color to red
            userNameTextField.layer.borderColor = UIColor.redColor().CGColor
            userNameTextField.layer.borderWidth = 1.0
            
        }
            
        //Check if password is empty
        
        else if(passwordTextField.text == ""){
            
            //if empty change password textfield border color to red
            passwordTextField.layer.borderColor = UIColor.redColor().CGColor
            passwordTextField.layer.borderWidth = 1.0
            
        }
            
        //if username and password is OK
            
        else if(userAndPassVerify(userNameTextField.text!, passWord:passwordTextField.text!))
        {
        
            //get the appdelegate and store it in a variable
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            //let rootViewController = appDelegate.window!.rootViewController
            
            //get the storyboard an store it in a variable
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            
            //Create and store the center the left and the right views and keep them in variables
            
            //center view
            let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController
            
            //left view
            let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("leftView") as! LeftViewController
            
            //right view
            let rightViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rightView") as! RightViewController
            
            
            //Set the left, right and center views as the rootviewcontroller for the navigation controller (one rootviewcontroller at a time)
            
            //Set the left view as the rootview for the navigation controller and keep it in a variable
            let leftSideNav = UINavigationController(rootViewController: leftViewController)

            //Set the center view as the rootview for the navigation controller and keep it in a variable
            let centerNav = UINavigationController(rootViewController: centerViewController)
            
            //Set the right view as the rootview for the navigation controller and keep it in a variable
            let rightNav = UINavigationController(rootViewController: rightViewController)
            
            //Create the MMDrawerController and keep it in a variable named center container
            let centerContainer:MMDrawerController = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:rightNav)
            
            
            //Open and Close gestures for the center container
            
            //Set the open gesture for the center container
            centerContainer.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView;
            //Set the close gesture for the center container
            centerContainer.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView;
            
            
            
            
            //Set the centerContainer in the appDelegate.swift as the center container
            appDelegate.centerContainer = centerContainer
            
            //Set the rootViewController as the center container
            appDelegate.window!.rootViewController = appDelegate.centerContainer
            
            
            appDelegate.window!.makeKeyAndVisible()
            
        }
        
        //if username or password is wrong
        
        else
        {
            //create an alert
            let alert = UIAlertView(title: "Warning!", message: "Check your username / password combination", delegate: self, cancelButtonTitle: "Dismiss")
            
            //empty textfields
            userNameTextField.text = ""
            passwordTextField.text = ""

            
            //show the alert
            alert.show()
            
            
        }
        
        
        
    }
    
    
    //Function to check username and password
    func userAndPassVerify(userName:String, passWord:String) -> Bool {
        
        //if user and pass is OK return true
        if(userName == "info@rocket.chat" && passWord == "123qwe"){
            
            return true
            
        }
        
        //if user and pass don't exist return false
            
        else
        {
            
            return false
        
        }
        
    }
    
    func textFieldDidChange() {
        
        //Reset textField's border color and width
        userNameTextField.layer.borderColor = UIColor.blackColor().CGColor
        userNameTextField.layer.borderWidth = 0.0
        passwordTextField.layer.borderColor = UIColor.blackColor().CGColor
        passwordTextField.layer.borderWidth = 0.0
        
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
