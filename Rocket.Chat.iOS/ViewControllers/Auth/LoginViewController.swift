//
//  LoginViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/8/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import MMDrawerController
import ObjectiveDDP

class LoginViewController: AuthViewController, UIPopoverPresentationControllerDelegate {
  
  @IBOutlet var userNameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  
  
  
  //variable to get the logged in user
  var meteor: MeteorClient!
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    meteor = ad.meteorClient
    
  
    let defaults = NSUserDefaults.standardUserDefaults()
    if let sessionToken = defaults.stringForKey("sessionToken") {
			print("sessionToken: \(sessionToken)")
    
    
    
    meteor.logonWithSessionToken(sessionToken, responseCallback: {(response, error) -> Void in
      
      if((error) != nil) {
        print("error!!! \(error)")
        return
      }
      print(response)
    })

    // TODO: check if session token exists and try to login with that.
    
    }
    
  }
  
  
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
    
    
    validateFields()
    
    
    loginToServer(userNameTextField.text!, pass: passwordTextField.text!)
    
    
  }
  
  func loginToServer(userName: String, pass: String) {
    if (!meteor.websocketReady) {
      let notConnectedAlert = UIAlertView(title: "Connection Error", message: "Can't find the Rocket.Chat server, try again", delegate: nil, cancelButtonTitle: "OK")
      notConnectedAlert.show()
      return
    }
    
    meteor.logonWithUsernameOrEmail(userName, password: pass) {(response, error) -> Void in
      
      if((error) != nil) {
        self.handleFailedAuth(error)
        return
      }
      self.handleSuccessfulAuth(response)
    }
  }
  
  func handleSuccessfulAuth(response: NSDictionary) {
    
    
    let result = response["result"] as? NSDictionary
    if (result == nil) {
      let err = NSError(domain: "Rocket.chat", code: 500, userInfo: ["msg": "empty result"])
      self.handleFailedAuth(err)
      return
    }
    
    
    
    if (getTokenAndSaveUser(userNameTextField.text!, response: response)){
     	createMainMMDrawer()
    }
  }
  
  func handleFailedAuth(error: NSError) {
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
  
  func validateFields(){
    //Check if username is empty
    
    if(userNameTextField.text == nil || userNameTextField.text!.isEmpty){
      
      //if empty change username textfield border color to red
      userNameTextField.layer.borderColor = UIColor.redColor().CGColor
      userNameTextField.layer.borderWidth = 1.0
      
      let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("loginPopover")
      popoverVC!.modalPresentationStyle = .Popover
      popoverVC!.preferredContentSize = CGSizeMake(250, 50)
      
      
      if let popoverController = popoverVC!.popoverPresentationController {
        
        //Specify the anchor location
        popoverController.sourceView = userNameTextField
        popoverController.sourceRect = userNameTextField.bounds
        
        //Popover above the textfield
        popoverController.permittedArrowDirections = .Down
        popoverController.delegate = self
      }
      
      //Show the popover
      presentViewController(popoverVC!, animated: true, completion: nil)
      
    }else if(passwordTextField.text == nil || passwordTextField.text!.isEmpty){
      
      //if empty change password textfield border color to red
      passwordTextField.layer.borderColor = UIColor.redColor().CGColor
      passwordTextField.layer.borderWidth = 1.0
      
      let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("loginPopover")
      popoverVC!.modalPresentationStyle = .Popover
      popoverVC?.preferredContentSize = CGSizeMake(250, 50)
      
      if let popoverController = popoverVC!.popoverPresentationController {
        
        //Specify the anchor location
        popoverController.sourceView = passwordTextField
        popoverController.sourceRect = passwordTextField.bounds
        
        //Popover above the textfield
        popoverController.permittedArrowDirections = .Down
        popoverController.delegate = self
        
        //Show the popover
        presentViewController(popoverVC!, animated: true, completion: nil)
        
      }
      
    }
  }
  
  
  
  func textFieldDidChange() {
    
    //Reset textField's border color and width
    userNameTextField.layer.borderColor = UIColor.blackColor().CGColor
    userNameTextField.layer.borderWidth = 0.0
    passwordTextField.layer.borderColor = UIColor.blackColor().CGColor
    passwordTextField.layer.borderWidth = 0.0
    
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
