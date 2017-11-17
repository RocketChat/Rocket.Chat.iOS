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

    let infoRequestHandler = InfoRequestHandler()

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

        infoRequestHandler.delegate = self
        infoRequestHandler.validateServerVersion = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()

        labelAuthenticationStatus.isHidden = true
        buttonConnect.isHidden = true
        activityIndicator.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let auth = AuthManager.isAuthenticated() {
            AuthManager.persistAuthInformation(auth)

            if let url = auth.apiHost {
                infoRequestHandler.validate(with: url)
            }
        } else {
            let storyboardAuth = UIStoryboard(name: "Auth", bundle: Bundle.main)
            let controller = storyboardAuth.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.keyWindow {
                window.rootViewController = controller
            }
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

    func resumeAuth() {
        guard let auth = AuthManager.isAuthenticated() else { return }

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
                SubscriptionManager.subscribeRoomChanges()
                PermissionManager.changes()
                PermissionManager.updatePermissions()

                if let userIdentifier = auth.userId {
                    PushManager.updateUser(userIdentifier)
                }

                self?.openChat()
            })
        })
    }

}

extension MainViewController: InfoRequestHandlerDelegate {

    var viewControllerToPresentAlerts: UIViewController? { return self }

    func urlNotValid() {
        // Do nothing
    }

    func serverIsValid() {
        DispatchQueue.main.async {
            self.resumeAuth()
        }
    }

    func serverChangedURL(_ newURL: String?) {
        guard
            let url = URL(string: newURL ?? ""),
            let socketURL = url.socketURL()
        else {
            return self.resumeAuth()
        }

        let newIndex = DatabaseManager.copyServerInformation(
            from: DatabaseManager.selectedIndex,
            with: socketURL.absoluteString
        )

        DatabaseManager.selectDatabase(at: newIndex)
        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()
        AuthManager.recoverAuthIfNeeded()

        DispatchQueue.main.async {
            guard
                let auth = AuthManager.isAuthenticated(),
                let apiHost = auth.apiHost
            else {
                return
            }

            self.infoRequestHandler.validate(with: apiHost)
        }
    }

}
