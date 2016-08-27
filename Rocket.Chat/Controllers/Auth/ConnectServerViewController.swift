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
    

    // MARK: IBAction
    
    @IBAction func buttonConnectPressed(sender: AnyObject) {
        guard let url = NSURL(string: textFieldServerURL.text!) else {
            let alert = UIAlertController(
                title: localizedString("alert.connection.invalid_url.title"),
                message: localizedString("alert.connection.invalid_url.message"),
                preferredStyle: .Alert
            )
            
            alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .Default, handler: nil))
            alert.showViewController(self, sender: sender)
            return
        }
        
        let socketURL = url.socketURL()
        SocketManager.connect(socketURL) { [unowned self] (socket, connected) in
            if connected {
                self.performSegueWithIdentifier("Auth", sender: nil)
            }
        }
    }
    
}
