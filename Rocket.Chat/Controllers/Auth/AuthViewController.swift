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

        SocketManager.sendMessage(object) { [unowned self] (response) in
            let auth = Auth()
            auth.serverURL = self.serverURL!
            auth.token = response["result"]["token"].string
            
            if let date = response["result"]["tokenExpires"]["$date"].double {
                auth.tokenExpires = NSDate(timeIntervalSince1970:date)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(auth)
            }

            Log.debug("\(realm.objects(Auth.self))")
        }
    }

}