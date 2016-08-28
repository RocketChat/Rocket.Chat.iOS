//
//  ConnectServerViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class ConnectServerViewController: BaseViewController {

    internal let defaultURL = "https://demo.rocket.chat"
    internal var connecting = false
    internal var serverURL: NSURL!
    
    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldServerURL: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nav = navigationController as! BaseNavigationController
        nav.setTransparentTheme()
        nav.navigationBar.barStyle = .Black

        textFieldServerURL.placeholder = defaultURL
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
        
        textFieldServerURL.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Auth" {
            let controller = segue.destinationViewController as! AuthViewController
            controller.serverURL = serverURL
        }
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
    
    func alertInvalidURL() {
        let alert = UIAlertController(
            title: localizedString("alert.connection.invalid_url.title"),
            message: localizedString("alert.connection.invalid_url.message"),
            preferredStyle: .Alert
        )
        
        alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func connect() {
        var text = textFieldServerURL.text!
        if text.characters.count == 0 {
            text = defaultURL
        }
        
        guard let url = NSURL(string: text) else { return alertInvalidURL() }
        guard let socketURL = url.socketURL() else { return alertInvalidURL() }
        
        connecting = true
        textFieldServerURL.alpha = 0.5
        activityIndicator.startAnimating()
        
        serverURL = socketURL
        
        SocketManager.connect(socketURL) { [unowned self] (socket, connected) in
            if connected {
                self.performSegueWithIdentifier("Auth", sender: nil)
            }
        
            self.connecting = false
            self.textFieldServerURL.alpha = 1
            self.activityIndicator.stopAnimating()
        }
    }
    
}


extension ConnectServerViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return !connecting
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        connect()
        return true
    }
    
}
