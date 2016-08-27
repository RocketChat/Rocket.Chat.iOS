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
    
    @IBOutlet weak var textFieldServerURL: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldServerURL.placeholder = defaultURL
    }
    
    
    // MARK: IBAction
    
    @IBAction func buttonConnectPressed(sender: AnyObject) {
        var text = textFieldServerURL.text!
        if text.characters.count == 0 {
            text = defaultURL
        }

        guard let url = NSURL(string: text) else { return alertInvalidURL() }
        guard let socketURL = url.socketURL() else { return alertInvalidURL() }

        SocketManager.connect(socketURL) { [unowned self] (socket, connected) in
            if connected {
                self.performSegueWithIdentifier("Auth", sender: nil)
            }
        }
    }
    
    func alertInvalidURL() {
        let alert = UIAlertController(
            title: localizedString("alert.connection.invalid_url.title"),
            message: localizedString("alert.connection.invalid_url.message"),
            preferredStyle: .Alert
        )
        
        alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
