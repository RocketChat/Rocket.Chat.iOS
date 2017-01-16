//
//  MainViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

final class MainViewController: BaseViewController {

    @IBOutlet weak var labelAuthenticationStatus: UILabel!
    @IBOutlet weak var buttonConnect: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if AuthManager.isAuthenticated() == nil {
            performSegue(withIdentifier: "Auth", sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let auth = AuthManager.isAuthenticated() {
            labelAuthenticationStatus.text = "Logging in..."
            buttonConnect.isEnabled = true

            AuthManager.resume(auth, completion: { [weak self] response in
                guard !response.isError() else {
                    self?.labelAuthenticationStatus.text = "User is not authenticated"
                    self?.buttonConnect.isEnabled = true
                    return
                }

                self?.labelAuthenticationStatus.text = "User is authenticated with token \(auth.token) on \(auth.serverURL)."

                SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                    // TODO: Move it to somewhere else
                    AuthManager.updatePublicSettings(auth, completion: { _ in

                    })

                    UserManager.changes()
                    SubscriptionManager.changes(auth)

                    // Open chat
                    let storyboardChat = UIStoryboard(name: "Chat", bundle: Bundle.main)
                    let controller = storyboardChat.instantiateInitialViewController()
                    let application = UIApplication.shared

                    if let window = application.keyWindow {
                        window.rootViewController = controller
                    }
                })
            })
        } else {
            labelAuthenticationStatus.text = "User is not authenticated."
            buttonConnect.isEnabled = true
        }
    }

}
