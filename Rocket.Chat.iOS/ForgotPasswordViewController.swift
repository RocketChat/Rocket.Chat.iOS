//
//  ForgotPasswordViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/26/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import JSQCoreDataKit

class ForgotPasswordViewController: UIViewController, UIPopoverPresentationControllerDelegate {

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
    
    //Function to return popovers as modals to all devices.
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
        
    }
    
    
    //Submiting username or email to recover password Function
    @IBAction func submitToRecoverPassword(sender: AnyObject) {
    }
    
    
}
