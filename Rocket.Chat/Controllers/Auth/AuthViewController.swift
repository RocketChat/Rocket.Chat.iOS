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
    
    var serverURL: NSURL!
    
    @IBOutlet weak var labelHost: UILabel!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelHost.text = serverURL.host!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
        
        textFieldUsername.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: Keyboard Handlers
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            visibleViewBottomConstraint.constant = CGRectGetHeight(keyboardSize)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        visibleViewBottomConstraint.constant = 0
    }
    
    
    // MARK: IBAction
    
    func authenticate() {
        let email = textFieldUsername.text!
        let password = textFieldPassword.text!
        
        AuthManager.auth(email, password: password) { [unowned self] (response) in
            if response.isError() {
                
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

}


extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == textFieldUsername {
            textFieldPassword.becomeFirstResponder()
        }
        
        if textField == textFieldPassword {
            authenticate()
        }
        
        return true
    }
    
}