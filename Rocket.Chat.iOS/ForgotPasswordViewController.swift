//
//  ForgotPasswordViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class ForgotPasswordViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var userNameOrEmail: UITextField!
  
  var meteor: MeteorClient!
    
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
      
        if(userNameOrEmail.text != "" ){
            meteor.callMethodName("sendForgotPasswordEmail", parameters: [userNameOrEmail.text!], responseCallback: {(response, error) -> Void in
                
                if((error) != nil) {
                    self.handleError(error)
                    return
                }
                self.handleSuccess(response)
            })
        }
      
    }
    
  func handleSuccess(response: NSDictionary){
    print("sent Password email")
  }
    
  
  func handleError(error: NSError){
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
