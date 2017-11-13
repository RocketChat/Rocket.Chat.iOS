//
//  RegisterUsernameViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 04/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON

final class RegisterUsernameViewController: BaseViewController {

    internal var requesting = false

    var serverPublicSettings: AuthSettings?

    @IBOutlet weak var viewFields: UIView! {
        didSet {
            viewFields.layer.cornerRadius = 4
            viewFields.layer.borderColor = UIColor.RCLightGray().cgColor
            viewFields.layer.borderWidth = 0.5
        }
    }

    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )

        textFieldUsername.becomeFirstResponder()
    }

    func startLoading() {
        textFieldUsername.alpha = 0.5
        requesting = true
        activityIndicator.startAnimating()
        textFieldUsername.resignFirstResponder()
    }

    func stopLoading() {
        textFieldUsername.alpha = 1
        requesting = false
        activityIndicator.stopAnimating()
    }

    // MARK: Keyboard Handlers
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            visibleViewBottomConstraint.constant = keyboardSize.height
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        visibleViewBottomConstraint.constant = 0
    }

    // MARK: Request username
    fileprivate func requestUsername() {
        startLoading()

        AuthManager.setUsername(textFieldUsername.text ?? "") { [weak self] (response) in
            self?.stopLoading()

            if response.isError() {
                if let error = response.result["error"].dictionary {
                    let alert = UIAlertController(
                        title: localized("error.socket.default_error_title"),
                        message: error["message"]?.string ?? localized("error.socket.default_error_message"),
                        preferredStyle: .alert
                    )

                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            } else {
                self?.dismiss(animated: true, completion: nil)

                let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
                let controller = storyboardChat.instantiateInitialViewController()
                let application = UIApplication.shared

                if let window = application.windows.first {
                    window.rootViewController = controller
                }
            }
        }
    }

}

extension RegisterUsernameViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !requesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestUsername()
        return true
    }

}
