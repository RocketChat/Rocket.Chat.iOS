//
//  ForgotPasswordViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit

class ForgotPasswordViewController: UIViewController {

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
    
    
    @IBAction func submitToRecoverPassword(sender: AnyObject) {
        
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
        
    }
    
    
}
