//
//  ForgotPasswordViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit

class ForgotPasswordViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var userNameOrEmail: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    
    //Submiting username or email to recover password Function
    @IBAction func submitToRecoverPassword(sender: AnyObject) {
        
        //If user submits username or email
        if userNameOrEmail.text != "" {
            
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let context = appDel.stack!.context
            
            //Check for already logged in user
            let ent = entity(name: "User", context: context)
            
            let request = FetchRequest<User>(entity: ent)
            //Users that we have password for only
            request.predicate = NSPredicate(format: "username == '\(userNameOrEmail.text!)'")
            
            var user = [User]()
            
            do{
                user = try fetch(request: request, inContext: context)
            }catch{
                print("User doesn't exist \(error)")
            }
            
            if !user.isEmpty{
                
                print("Found user \(user[0].username)")
                
                self.performSegueWithIdentifier("returnToLogin", sender: self)
                
                let alert = UIAlertView(title: "Password recovered", message: "An email has been sent to your email account", delegate: self, cancelButtonTitle: "Dismiss")
                alert.show()
            
            }else{
                
                let alert = UIAlertView(title: "Not Found", message: "This username or email doesn't exist in our database. Please check again", delegate: self, cancelButtonTitle: "Dismiss")
                alert.show()
            }
            
        }
        //If user submits empty data
        else {
            
            //Create popover
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("forgotPasswordPopover")
            
            //Set it as popover
            popoverVC?.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC?.preferredContentSize = CGSizeMake(250, 55)
            
            if let popoverController = popoverVC?.popoverPresentationController {
                
                //specify the anchor location
                popoverController.sourceView = userNameOrEmail
                popoverController.sourceRect = userNameOrEmail.bounds
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
                
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        }
        
    }
    
    
}
