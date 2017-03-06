//
//  MainViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SideMenu

final class MainViewController: BaseViewController {

    @IBOutlet weak var labelAuthenticationStatus: UILabel!
    @IBOutlet weak var buttonConnect: UIButton!

    var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var activityIndicatorContainer: UIView! {
        didSet {
            let width = activityIndicatorContainer.bounds.width
            let height = activityIndicatorContainer.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let activityIndicator = NVActivityIndicatorView(
                frame: frame,
                type: .ballPulse,
                color: UIColor.RCBlue(),
                padding: 0
            )

            activityIndicatorContainer.addSubview(activityIndicator)
            self.activityIndicator = activityIndicator
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let leftMenuController = SideMenuManager.menuLeftNavigationController {
            leftMenuController.dismiss(animated: false, completion: {
                SideMenuManager.menuLeftNavigationController = nil
                SideMenuManager.menuLeftSwipeToDismissGesture = nil
                SideMenuManager.menuRightNavigationController = nil
                SideMenuManager.menuRightSwipeToDismissGesture = nil
            })
        }

        if AuthManager.isAuthenticated() == nil {
            performSegue(withIdentifier: "Auth", sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let auth = AuthManager.isAuthenticated() {
            labelAuthenticationStatus.isHidden = true
            buttonConnect.isHidden = true
            activityIndicator.startAnimating()

            AuthManager.resume(auth, completion: { [weak self] response in
                guard !response.isError() else {
                    self?.labelAuthenticationStatus.isHidden = false
                    self?.buttonConnect.isHidden = false
                    self?.activityIndicator.stopAnimating()
                    return
                }

                SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                    AuthManager.updatePublicSettings(auth, completion: { _ in

                    })

                    UserManager.userDataChanges()
                    UserManager.changes()
                    SubscriptionManager.changes(auth)

                    if let userIdentifier = auth.userId {
                        PushManager.updateUser(userIdentifier)
                    }

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
            buttonConnect.isEnabled = true
        }
    }

}
