//
//  MainViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class MainViewController: BaseViewController {

    @IBOutlet weak var labelAuthenticationStatus: UILabel!
    @IBOutlet weak var buttonConnect: UIButton!

    var activityIndicator: LoaderView!
    @IBOutlet weak var activityIndicatorContainer: UIView! {
        didSet {
            let width = activityIndicatorContainer.bounds.width
            let height = activityIndicatorContainer.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let activityIndicator = LoaderView(frame: frame)
            activityIndicatorContainer.addSubview(activityIndicator)
            self.activityIndicator = activityIndicator
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthManager.recoverAuthIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if AuthManager.isAuthenticated() == nil {
            performSegue(withIdentifier: "Auth", sender: nil)
        }

        if !NetworkManager.isConnected {
            openChat()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()

        if let auth = AuthManager.isAuthenticated() {
            AuthManager.persistAuthInformation(auth)

            labelAuthenticationStatus.isHidden = true
            buttonConnect.isHidden = true
            activityIndicator.startAnimating()

            if NetworkManager.isConnected {
                AuthManager.resume(auth, completion: { [weak self] response in
                    guard !response.isError() else {
                        self?.labelAuthenticationStatus.isHidden = false
                        self?.buttonConnect.isHidden = false
                        self?.activityIndicator.stopAnimating()

                        self?.openChat()

                        return
                    }

                    SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                        AuthSettingsManager.updatePublicSettings(auth, completion: { _ in

                        })

                        UserManager.userDataChanges()
                        UserManager.changes()
                        SubscriptionManager.changes(auth)

                        if let userIdentifier = auth.userId {
                            PushManager.updateUser(userIdentifier)
                        }

                        self?.openChat()
                    })
                })
            }
        } else {
            buttonConnect.isEnabled = true
        }
    }

    func openChat() {
        let storyboardChat = UIStoryboard(name: "Chat", bundle: Bundle.main)
        let controller = storyboardChat.instantiateInitialViewController()
        let application = UIApplication.shared

        if let window = application.keyWindow {
            window.rootViewController = controller
        }
    }

}
