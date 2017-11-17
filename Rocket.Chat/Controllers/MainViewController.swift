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
            } else {
                WindowManager.open(.chat)
            }
        } else {
            WindowManager.open(.auth)
        }
    }
 
}

extension MainViewController: InfoRequestHandlerDelegate {

    var viewControllerToPresentAlerts: UIViewController? { return self }

    func urlNotValid() {
        // Do nothing
    }

    func serverIsValid() {
        DispatchQueue.main.async {
            WindowManager.open(.chat)
        }
    }

    func serverChangedURL(_ newURL: String?) {
        guard
            let url = URL(string: newURL ?? ""),
            let socketURL = url.socketURL()
        else {
            return WindowManager.open(.chat)
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
