//
//  UsernameRegistrationViewController.swift
//  Rocket.Chat.iOS
//
//  Created by giorgos on 9/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class UsernameRegistrationViewController: UIViewController {
  
  @IBOutlet weak var usernameField: UITextField!
  var meteor: MeteorClient!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    meteor = ad.meteorClient
    
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //retrieve username suggestions from server
    meteor.callMethodName("getUsernameSuggestion", parameters: nil, responseCallback: {(response, error) -> Void in
      
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
    
    let params = NSDictionary(dictionary: ["username": usernameField.text!])
    meteor.callMethodName("setUsername", parameters: [params], responseCallback: {(response, error) -> Void in
      
      if((error) != nil) {
        self.handleFailedUsernameReg(error)
        return
      }
      self.handleSuccessfulUsernameReg(response)
    })

    
  }

  // MARK: SetUsernameHandlers
  func handleSuccessfulUsernameReg(response: NSDictionary){
    
    
  }

  func handleFailedUsernameReg(error: NSError){
  }

  
  
  
  // MARK: LoadUsernamesHandlers
  func handleFailedUsernameLoad(error: NSError){
    //don't set username placeholder.
  }
  
  func handleSuccessfulUsernameLoad(response: NSDictionary){
    let res = response["result"] as? NSDictionary
    if (res != nil){
      let usernames = res!["usernames"] as? NSArray
      if (usernames != nil){
        usernameField.text = usernames![0] as? String
      }
    }
  }
  
}
