//
//  TwoFactorAuthTableViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 30/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON

final class TwoFactorAuthTableViewController: BaseTableViewController {

    internal var requesting = false

    var username: String = ""
    var password: String = ""
    var token: String = ""

    @IBOutlet weak var textFieldCode: UITextField!
    @IBOutlet weak var confirmButton: StyledButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = SocketManager.sharedInstance.serverURL?.host
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldCode.text = token
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if token.isEmpty {
            textFieldCode.becomeFirstResponder()
        } else {
            authenticate()
        }
    }

    func startLoading() {
        textFieldCode.alpha = 0.5
        requesting = true
        confirmButton.startLoading()
        textFieldCode.resignFirstResponder()
    }

    func stopLoading() {
        textFieldCode.alpha = 1
        requesting = false
        confirmButton.stopLoading()
    }

    // MARK: Request username

    @IBAction func didPressedConfirmButton() {
        guard !requesting else {
            return
        }

        authenticate()
    }

    fileprivate func authenticate() {
        startLoading()

        func presentErrorAlert(message: String? = nil) {
            Alert(
                title: localized("error.socket.default_error.title"),
                message: message ?? localized("error.socket.default_error.message")
            ).present()
        }

        AuthManager.auth(username, password: password, code: textFieldCode.text ?? "") { [weak self] (response) in
            self?.stopLoading()

            switch response {
            case .resource(let resource):
                if let error = resource.error {
                    return presentErrorAlert(message: error)
                }

                self?.dismiss(animated: true, completion: nil)
                AppManager.reloadApp()
            case .error:
                presentErrorAlert()
            }
        }
    }

}

extension TwoFactorAuthTableViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !requesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !requesting {
            authenticate()
        }

        return true
    }

}
