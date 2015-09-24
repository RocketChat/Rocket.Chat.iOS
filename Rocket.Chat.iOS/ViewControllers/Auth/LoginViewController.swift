//
//  LoginViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/8/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit
import MMDrawerController
import ObjectiveDDP

class LoginViewController: UIViewController, UIPopoverPresentationControllerDelegate {
  
  @IBOutlet var userNameTextField: UITextField!
  @IBOutlet var passwordTextField: UITextField!
  
  
  
  //variable to get the logged in user
  var currentUser = User?()
  var users = [User]()
  var meteor: MeteorClient!

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let ad = UIApplication.sharedApplication().delegate as! AppDelegate
    meteor = ad.meteorClient
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
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = delegate.stack!.context
    
    //Check for already logged in user
    let ent = entity(name: "User", context: context)
    
    let request = FetchRequest<User>(entity: ent)
    //Users that we have password for only
    request.predicate = NSPredicate(format: "password != nil")
    
    
    users = [User]()
    do{
      users = try fetch(request: request, inContext: context)
    }catch{
      print("Error fetching users \(error)")
    }
    
    //        if exists {
    //            loginButtonTapped(userNameTextField.text!)
    //        }
    
    //        if !users.isEmpty {
    //            userNameTextField.text = users[0].username
    //            passwordTextField.text = users[0].password
    //            loginButtonTapped(users)
    //        }
    
    
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

    let token = result!["token"] as? NSString
    // TODO: store token.

    self.view.endEditing(true)

    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)


    //Create and store the center the left and the right views and keep them in variables

    //center view
    let centerViewController = mainStoryboard.instantiateViewControllerWithIdentifier("viewController") as! ViewController

    //left view
    let leftViewController = mainStoryboard.instantiateViewControllerWithIdentifier("leftView") as! LeftViewController

    //right view
    let rightViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rightView") as! RightViewController


    // FIXME: see why we need the currentUser
    //send the logged in user in the ViewController
    centerViewController.currentUser = currentUser

    //Set the left, right and center views as the rootviewcontroller for the navigation controller (one rootviewcontroller at a time)

    let leftSideNav = UINavigationController(rootViewController: leftViewController)
    leftSideNav.setNavigationBarHidden(true, animated: false)
    let centerNav = UINavigationController(rootViewController: centerViewController)
    let rightNav = UINavigationController(rootViewController: rightViewController)

    //Create the MMDrawerController and keep it in a variable named center container
    let centerContainer:MMDrawerController = MMDrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:rightNav)

    //Open and Close gestures for the center container

    centerContainer.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView;
    centerContainer.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView;

    //Setting the width of th right view
    //centerContainer.setMaximumRightDrawerWidth(appDelegate.window!.frame.width, animated: true, completion: nil)
    
    //Set the centerContainer in the appDelegate.swift as the center container
    appDelegate.centerContainer = centerContainer

    //Set the rootViewController as the center container
    appDelegate.window!.rootViewController = appDelegate.centerContainer
    appDelegate.window!.makeKeyAndVisible()

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
