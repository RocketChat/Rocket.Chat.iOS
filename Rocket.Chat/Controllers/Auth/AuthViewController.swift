//
//  AuthViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AuthViewController: BaseViewController {
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    // MARK: IBAction
    
    @IBAction func buttonAuthenticatePressed(sender: AnyObject) {
        let email = textFieldUsername.text!
        let password = textFieldPassword.text!
        
        AuthManager.auth(email, password: password) { (response) in
            if response.isError() {
                
            } else {
                
            }
        }
    }

}