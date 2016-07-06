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
    
    @IBOutlet weak var textFieldServerURL: UITextField!
    
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Auth" {
            let controller = segue.destinationViewController as! AuthViewController
            controller.serverURL = textFieldServerURL.text!
        }
    }
    
    
    // MARK: IBAction
    
    @IBAction func buttonConnectPressed(sender: AnyObject) {
        let url = NSURL(string: textFieldServerURL.text!)!
        SocketManager.connect(url)

        self.performSegueWithIdentifier("Auth", sender: nil)
    }
    
}
