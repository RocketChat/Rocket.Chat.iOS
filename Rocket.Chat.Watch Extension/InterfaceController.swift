//
//  InterfaceController.swift
//  Rocket.Chat.Watch Extension
//
//  Created by ahmed on 4/12/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var label: WKInterfaceLabel!
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print(message)
        let username = "Hello " + String(describing: message["username"] as? String ?? "Failed")
        label.setText(username)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("---Can Communicate")
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if WCSession.isSupported() {
            let wcsession = WCSession.default
            wcsession.delegate = self
            wcsession.activate()
        }
    }
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
















