//
//  RegisterViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit

class RegisterViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the password and confirm password as secure text
        passwordTextField.secureTextEntry = true
        confirmPasswordTextField.secureTextEntry = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    
    //Function to return popovers as modals to all devices.
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
        
    }
    
    
    //Registration
    @IBAction func submitToRegister(sender: AnyObject) {
        
        //Boolean to check text inputs
        var checkOK = false
        
        //Check inputs
        
        //Reset text input borders
        nameTextField.layer.borderColor = UIColor.blackColor().CGColor
        nameTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.blackColor().CGColor
        emailTextField.layer.borderWidth = 0
        passwordTextField.layer.borderColor = UIColor.blackColor().CGColor
        passwordTextField.layer.borderWidth = 0
        
        
        //Name check
        if (nameTextField.text!.isEmpty){
            
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.layer.borderWidth = 1
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("namePopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 50)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = nameTextField
                popoverController.sourceRect = nameTextField.bounds

                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        
        }
        
        //then email check
        else if emailTextField.text!.isEmpty || !isValidEmail(emailTextField.text!) {
            
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.layer.borderWidth = 1
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("emailPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 50)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = emailTextField
                popoverController.sourceRect = emailTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)

        }
        
        //then password check
        else if (passwordTextField.text!.characters.count < 8) {
            
            passwordTextField.layer.borderColor = UIColor.redColor().CGColor
            passwordTextField.layer.borderWidth = 1
            
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("passwordPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 55)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = passwordTextField
                popoverController.sourceRect = passwordTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)

            
        }
        
        //Do we want the password and confirmPassword trimmed?
        //Confirm password
        else if passwordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != confirmPasswordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
            
//            let alert = UIAlertView(title: "Confirm Password", message: "Please Confirm Your Password", delegate: self, cancelButtonTitle: "Dismiss")
//            alert.show()
            
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("confirmPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 55)
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = confirmPasswordTextField
                popoverController.sourceRect = confirmPasswordTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        }
        
        //All good
        else
        {
            checkOK = true
        }
            
        
            
        //everything is good so let's register
        if checkOK {
            
        
            //get the appdelegate and store it in a variable
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.stack!.context
            
            
            //Check for already logged in user
            let ent = entity(name: "User", context: context)
            
            
            //Create the request
            let request = FetchRequest<User>(entity: ent)
            //Users that we have password for only
            request.predicate = NSPredicate(format: "password != nil")
            
            
            //Array to keep the users
            var users = [User]()
            
            //Fetch the users and store them in the array
            do{
                users = try fetch(request: request, inContext: context)
            }catch{
                print("Error fetching users \(error)")
            }
            
            
            //Check if the username exists
            var exists = false
            
            for i in users {
                
                if i.username == nameTextField.text{
                    exists = true
                    print("Name Exists")
                }
            }
            
            
            
            //If it doesn't exist
            if !exists{
                
                //Create the user
                let user = User(context: context, id: "NON-YET", username: nameTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), avatar: UIImage(named: "Default-Avatar")!, status: .ONLINE, timezone: NSTimeZone.systemTimeZone())
                
                //Set the password
                user.password = passwordTextField.text!
                
                //User is automatically is added to CoreData, but not saved, so we need to call
                //save context next.
                
                //Save the user
                saveContext(context, wait: true, completion:{(error: NSError?) -> Void in
                    if let err = error {
                        let alert = UIAlertController(title: "Alert", message: "Error \(err.userInfo)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                })
                
                
                //Go back to login screen
                self.performSegueWithIdentifier("returnToLogin", sender: self)
                
                
                //Inform the registered user
                let alert = UIAlertView(title: "Registered", message: "Registration Completed! You can log in now!", delegate: self, cancelButtonTitle: "Dismiss")
                alert.show()
                
                
                
            }
                
            //If the user exists
            else{
                
                //Inform the not-registered user
                let alert = UIAlertView(title: "Name Exists", message: "Username not available", delegate: self, cancelButtonTitle: "Dismiss")
                alert.show()
            }
            
            
            
        }
        
    }

    
    //Dismissing the keyboard
    @IBAction func dismissKeyboard(sender: AnyObject) {
        
        self.resignFirstResponder()
        
    }
    
    
    //Email validation
    func isValidEmail(email:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailCheck = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailCheck.evaluateWithObject(email)
    }
    
    
}
