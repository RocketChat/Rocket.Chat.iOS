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

        navigationItem.title = SocketManager.sharedInstance.serverURL?.host

        startLoading()
        AuthManager.usernameSuggestion { [weak self] (response) in
            self?.stopLoading()

            if !response.isError() {
                self?.textFieldUsername.text = response.result["result"].stringValue
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldUsername.becomeFirstResponder()
    }

    func startLoading() {
        textFieldUsername.alpha = 0.5
        requesting = true
        registerButton.startLoading()
        textFieldUsername.resignFirstResponder()
    }

    func stopLoading() {
        textFieldUsername.alpha = 1
        requesting = false
        registerButton.stopLoading()
    }

    // MARK: Request username

    @IBAction func didPressedRegisterButton() {
        guard !requesting else {
            return
        }

        requestUsername()
    }

    fileprivate func requestUsername() {
        startLoading()

        AuthManager.setUsername(textFieldUsername.text ?? "") { [weak self] success, errorMessage in
            DispatchQueue.main.async {
            self?.stopLoading()
                if !success {
                    Alert(
                        title: localized("error.socket.default_error.title"),
                        message: errorMessage ?? localized("error.socket.default_error.message")
                    ).present()
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
