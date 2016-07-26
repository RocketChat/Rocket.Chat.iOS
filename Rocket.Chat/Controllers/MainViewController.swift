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
    @IBOutlet weak var buttonConnect: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let auth = AuthManager.isAuthenticated() {
            labelAuthenticationStatus.text = "Logging in..."
            buttonConnect.enabled = false
            
            AuthManager.resume(auth, completion: { [unowned self] (response) in
                guard !response.isError() else {
                    self.labelAuthenticationStatus.text = "User is not authenticated"
                    self.buttonConnect.enabled = true
                    return
                }
                
                self.labelAuthenticationStatus.text = "User is authenticated with token \(auth.token) on \(auth.serverURL)."
                
                SubscriptionManager.updateSubscriptions(auth, completion: { (response) in
                    let storyboardChat = UIStoryboard(name: "Chat", bundle: NSBundle.mainBundle())
                    let controller = storyboardChat.instantiateInitialViewController()
                    let application = UIApplication.sharedApplication()
                    
                    if let window = application.keyWindow {
                        window.rootViewController = controller
                    }
                })
            })
        } else {
            labelAuthenticationStatus.text = "User is not authenticated."
            buttonConnect.enabled = true
        }
    }
    
}