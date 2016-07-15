//
//  MainViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: BaseViewController {
    
    @IBOutlet weak var labelAuthenticationStatus: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let auth = AuthManager.isAuthenticated() {
            labelAuthenticationStatus.text = "User is authenticated with token \(auth.token) on \(auth.serverURL)."
            
            SubscriptionManager.updateSubscriptions(auth, completion: { (response) in
                Log.debug("\(auth.subscriptions)")
                
                if let subscription = auth.subscriptions.first {
                    MessageManager.fetchHistory(subscription, completion: { (response) in
                        Log.debug("\(MessageManager.allMessages(subscription))")
                    })
                }
            })
        } else {
            labelAuthenticationStatus.text = "User is not authenticated."
        }
    }
    
}