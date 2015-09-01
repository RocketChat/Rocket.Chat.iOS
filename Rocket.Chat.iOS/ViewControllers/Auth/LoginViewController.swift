//
//  LoginViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/8/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit
import MMDrawerController

class LoginViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    

    
    //variable to get the logged in user
    var currentUser = User?()
    var users = [User]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set password textfield to secure entry textfield
        passwordTextField.secureTextEntry = true
        
        //Add listener for the textinput for when input changes
        userNameTextField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        passwordTextField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
        
        //Prefill text inputs to make login easier for developing
//        userNameTextField.text = "info@rocket.chat"
//        passwordTextField.text = "123qwe"
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.stack!.context
        
        //Check for already logged in user
        let ent = entity(name: "User", context: context)
        
        let request = FetchRequest<User>(entity: ent)
        //Users that we have password for only
        request.predicate = NSPredicate(format: "password != nil")
        
        
        users = [User]()
        do{
            users = try fetch(request: request, inContext: context)
        }catch{
            print("Error fetching users \(error)")
        }
        
//        if exists {
//            loginButtonTapped(userNameTextField.text!)
//        }
        
//        if !users.isEmpty {
//            userNameTextField.text = users[0].username
//            passwordTextField.text = users[0].password
//            loginButtonTapped(users)
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Function to return popovers as modals to all devices.
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
        
    }
    

    //Login action
    @IBAction func loginButtonTapped(sender: AnyObject) {
        
        
        //Check if username is empty
        
        if(userNameTextField.text == ""){
            
            //if empty change username textfield border color to red
            userNameTextField.layer.borderColor = UIColor.redColor().CGColor
            userNameTextField.layer.borderWidth = 1.0
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("loginPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 50)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = userNameTextField
                popoverController.sourceRect = userNameTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        }
            
        //Check if password is empty
        
        else if(passwordTextField.text == ""){
            
            //if empty change password textfield border color to red
            passwordTextField.layer.borderColor = UIColor.redColor().CGColor
            passwordTextField.layer.borderWidth = 1.0
            
            
            //Create popover controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("loginPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC?.preferredContentSize = CGSizeMake(250, 50)
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = passwordTextField
                popoverController.sourceRect = passwordTextField.bounds
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
                
                //Show the popover
                presentViewController(popoverVC!, animated: true, completion: nil)

            }

        }
            
        //if username and password is OK
            
        else if(userAndPassVerify(userNameTextField.text!, passWord:passwordTextField.text!))
        {
        
            self.view.endEditing(true)
            //get the appdelegate and store it in a variable
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            
            //THIS NEEDS TO MOVE (?)
            
            
//            let context = appDelegate.stack!.context
//            
//            let user = User(context: context, id: "NON-YET", username: userNameTextField.text!, avatar: "avatar.png", status: .ONLINE, timezone: NSTimeZone.systemTimeZone())
//            user.password = passwordTextField.text!
//            //User is automatically is added to CoreData, but not saved, so we need to call
//            //save context next.
//            //This is dump, because it writes the same user again, and again
//            
//            saveContext(context, wait: true, completion:{(error: NSError?) -> Void in
//                if let err = error {
//                    let alert = UIAlertController(title: "Alert", message: "Error \(err.userInfo)", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//                
//            //set the logged in user
//            self.currentUser = user
//            
//                
//            })
            
            
            
            
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
            
            
            //send the logged in user in the ViewController
            centerViewController.currentUser = currentUser
            
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
            
            //Setting the width of th right view
            //centerContainer.setMaximumRightDrawerWidth(appDelegate.window!.frame.width, animated: true, completion: nil)
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
            
            //userNameTextField gets the focus
            userNameTextField.becomeFirstResponder()
            
        }
        
        
        
    }
    
    
    //Function to check username and password
    func userAndPassVerify(userName:String, passWord:String) -> Bool {
        
        
        var exists = false
        
        //If there are registered users
        if !self.users.isEmpty{
            
            for i in self.users {
                
                if i.username == userNameTextField.text && i.password == passwordTextField.text{
                    exists = true
                    self.currentUser = i
                    print("CurrentUser set " + i.username)
                }
            }
            
        }
        //if user and pass is OK return true
//        if(userName == "komic" && passWord == "komic123"){
//            
//            return true
//            
//        }
        
        
        //Return if exists or not
        return exists
        
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
