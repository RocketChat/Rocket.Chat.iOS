//
//  UsernameRegistrationViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 9/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class UsernameRegistrationViewController: AuthViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    var meteor: MeteorClient!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        meteor = ad.meteorClient
        
        print("set meteor client")
        
        let params = NSDictionary()
        
        //retrieve username suggestions from server
        meteor.callMethodName("getUsernameSuggestion", parameters: [params], responseCallback: {(response, error) -> Void in
            
            if((error) != nil) {
                self.handleFailedUsernameLoad(error)
                return
            }
            self.handleSuccessfulUsernameLoad(response)
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerUsername(sender: AnyObject) {
        
        if (usernameField.text == nil || usernameField.text!.isEmpty){
            return
        }
        
        meteor.callMethodName("setUsername", parameters: [usernameField.text!], responseCallback: {(response, error) -> Void in
            
            if((error) != nil) {
                self.handleFailedUsernameReg(error)
                return
            }
            self.handleSuccessfulUsernameReg(response)
        })
        
        
    }
    
    // MARK: SetUsernameHandlers
    func handleSuccessfulUsernameReg(response: NSDictionary){
        createMainMMDrawer()
    }
    
    func handleFailedUsernameReg(error: NSError){
        let alert = UIAlertView(title: "Sorry", message: "Failed to set username", delegate: self, cancelButtonTitle: "Dismiss")
        alert.show()
        print("\(error)")
        
    }
    
    
    
    
    // MARK: LoadUsernamesHandlers
    func handleFailedUsernameLoad(error: NSError){
        //don't set username placeholder.
    }
    
    func handleSuccessfulUsernameLoad(response: NSDictionary){
        let res = response["result"] as? String
        usernameField.text = res!
    }
    
}
