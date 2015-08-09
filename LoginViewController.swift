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
