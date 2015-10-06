//
//  RegisterViewController.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/24/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit
import ObjectiveDDP

class RegisterViewController: AuthViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    var meteor: MeteorClient!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let ad = UIApplication.sharedApplication().delegate as! AppDelegate
        meteor = ad.meteorClient
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the password and confirm password as secure text
        passwordTextField.secureTextEntry = true
        confirmPasswordTextField.secureTextEntry = true
        
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
    
    
    //Registration
    @IBAction func submitToRegister(sender: AnyObject) {
        
        
        //Check inputs
        
        //Reset text input borders
        nameTextField.layer.borderColor = UIColor.blackColor().CGColor
        nameTextField.layer.borderWidth = 0
        emailTextField.layer.borderColor = UIColor.blackColor().CGColor
        emailTextField.layer.borderWidth = 0
        passwordTextField.layer.borderColor = UIColor.blackColor().CGColor
        passwordTextField.layer.borderWidth = 0
        
        
        //Name check
        if (nameTextField.text!.isEmpty){
            
            nameTextField.layer.borderColor = UIColor.redColor().CGColor
            nameTextField.layer.borderWidth = 1
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("namePopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 50)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = nameTextField
                popoverController.sourceRect = nameTextField.bounds

                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        
        }
        
        //then email check
        else if emailTextField.text!.isEmpty || !isValidEmail(emailTextField.text!) {
            
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.layer.borderWidth = 1
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("emailPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 50)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = emailTextField
                popoverController.sourceRect = emailTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)

        }
        
        //then password check
        else if (passwordTextField.text!.characters.count < 8) {
            
            passwordTextField.layer.borderColor = UIColor.redColor().CGColor
            passwordTextField.layer.borderWidth = 1
            
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("passwordPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 55)
            
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = passwordTextField
                popoverController.sourceRect = passwordTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)

            
        }
        
        //Do we want the password and confirmPassword trimmed?
        //Confirm password
        else if passwordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != confirmPasswordTextField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) {
            
//            let alert = UIAlertView(title: "Confirm Password", message: "Please Confirm Your Password", delegate: self, cancelButtonTitle: "Dismiss")
//            alert.show()
            
            
            //Create View Controller
            let popoverVC = storyboard?.instantiateViewControllerWithIdentifier("confirmPopover")
            
            //Set it as popover
            popoverVC!.modalPresentationStyle = .Popover
            
            //Set the size
            popoverVC!.preferredContentSize = CGSizeMake(250, 55)
            
            if let popoverController = popoverVC!.popoverPresentationController {
                
                //Specify the anchor location
                popoverController.sourceView = confirmPasswordTextField
                popoverController.sourceRect = confirmPasswordTextField.bounds
                
                
                //Popover above the textfield
                popoverController.permittedArrowDirections = .Down
                
                //Set the delegate
                popoverController.delegate = self
            }
            
            //Show the popover
            presentViewController(popoverVC!, animated: true, completion: nil)
            
        }
        
        //All good
        else
        {
            let formData = NSDictionary(dictionary: [
                "email": emailTextField.text!,
                "pass": passwordTextField.text!,
                "name": nameTextField.text!
                ])
            meteor.callMethodName("registerUser", parameters: [formData], responseCallback: {(response, error) -> Void in
                
                if((error) != nil) {
                    self.handleFailedReg(error)
                    return
                }
                    self.handleSuccessfulReg(response)
            })
        }
            
    
    }
    
    
    
    /** Takes the user to the username registration form. */
    func handleSuccessfulReg(response: NSDictionary){
        
        // FIXME: look into whether we need this!!
        
        let res = response["id"] as? String
        if (res != nil){
            
            meteor.logonWithEmail(emailTextField.text!, password: passwordTextField.text!, responseCallback: {(response, error) -> Void in
                
                if((error) != nil) {
                    self.handleFailedReg(error)
                    return
                }
                self.handleSuccessfulLogin(response)
            })
            
            
        }
        
    }
    
    func handleSuccessfulLogin(response: NSDictionary){
        if(getTokenAndSaveUser(emailTextField.text!, response: response)){
            
            //Proceed to username selection screen.
            self.performSegueWithIdentifier("selectUsername", sender: self)
        }
        
    }
    
    func handleFailedReg(error: NSError){
        //Inform the not-registered user
        let alert = UIAlertView(title: "Sorry", message: "An error occurred during registration", delegate: self, cancelButtonTitle: "Dismiss")
        alert.show()
        
    }

    
    

    
    //Dismissing the keyboard
    @IBAction func dismissKeyboard(sender: AnyObject) {
        
        self.resignFirstResponder()
        
    }
    
    
    //Email validation
    func isValidEmail(email:String) -> Bool {
        
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailCheck = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailCheck.evaluateWithObject(email)
    }
    
    
}
