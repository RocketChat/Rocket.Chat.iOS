//
//  AuthViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class AuthViewController: BaseViewController {
    
    var serverURL: String?
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    // MARK: IBAction
    
    @IBAction func buttonAuthenticatePressed(sender: AnyObject) {

        let object = [
            "msg": "method",
            "method": "login",
            "params": [[
                "user": [
                    "email": textFieldUsername.text!
                ],
                "password": [
                    "digest": textFieldPassword.text!.sha256(),
                    "algorithm":"sha-256"
                ]
            ]]
        ]

        SocketManager.sendMessage(object) { (response) in
            Log.debug(response as! String)
        }
    }

}