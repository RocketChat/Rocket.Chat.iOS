//
//  RegisterUsernameTableViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 04/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON

final class RegisterUsernameTableViewController: BaseTableViewController {

    internal var requesting = false

    var serverPublicSettings: AuthSettings?

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var registerButton: StyledButton!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let serverURL = AuthManager.selectedServerInformation()?[ServerPersistKeys.serverURL], let url = URL(string: serverURL) {
            navigationItem.title = url.host
        } else {
            navigationItem.title = SocketManager.sharedInstance.serverURL?.host
        }

        if let nav = navigationController as? AuthNavigationController {
            nav.setGrayTheme()
        }

        setupAuth()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldUsername.becomeFirstResponder()
    }

    func startLoading() {
        DispatchQueue.main.async {
            self.textFieldUsername.alpha = 0.5
            self.requesting = true
            self.view.layoutIfNeeded()
            self.registerButton.startLoading()
            self.textFieldUsername.resignFirstResponder()
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            self.textFieldUsername.alpha = 1
            self.requesting = false
            self.registerButton.stopLoading()
        }
    }

    // MARK: Request username

    func setupAuth() {
        let presentGenericSocketError = {
            Alert(
                title: localized("error.socket.default_error.title"),
                message: localized("error.socket.default_error.message")
            ).present()
        }
        guard let auth = AuthManager.isAuthenticated() else {
            presentGenericSocketError()
            return
        }

        startLoading()
        AuthManager.resume(auth) { [weak self] response in
            self?.stopLoading()

            if response.isError() {
                presentGenericSocketError()
            } else {
                self?.startLoading()
                AuthManager.usernameSuggestion { (response) in
                    self?.stopLoading()

                    if !response.isError() {
                        DispatchQueue.main.async {
                            self?.textFieldUsername.text = response.result["result"].stringValue
                        }
                    }
                }
            }
        }
    }

    @IBAction func didPressedRegisterButton() {
        guard !requesting else {
            return
        }

        requestUsername()
    }

    fileprivate func requestUsername() {
        let error = { (errorMessage: String?) in
            Alert(
                title: localized("error.socket.default_error.title"),
                message: errorMessage ?? localized("error.socket.default_error.message")
            ).present()
        }

        guard let username = textFieldUsername.text, !username.isEmpty else {
            return error(nil)
        }

        startLoading()
        AuthManager.setUsername(textFieldUsername.text ?? "") { [weak self] success, errorMessage in
            DispatchQueue.main.async {
            self?.stopLoading()
                if !success {
                    error(errorMessage)
                } else {
                    self?.dismiss(animated: true, completion: nil)
                    AppManager.reloadApp()
                }
            }
        }
    }

}

extension RegisterUsernameTableViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !requesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !requesting {
            requestUsername()
        }
        return true
    }

}

// MARK: Disable Theming

extension RegisterUsernameTableViewController {
    override func applyTheme() { }
}
