//
//  SignupViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SwiftyJSON

final class SignupViewController: BaseViewController {

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
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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

        textFieldName.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }

    func startLoading() {
        textFieldName.alpha = 0.5
        textFieldEmail.alpha = 0.5
        textFieldPassword.alpha = 0.5
        
        requesting = true
        activityIndicator.startAnimating()
        textFieldName.resignFirstResponder()
        textFieldEmail.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
    }

    func stopLoading() {
        textFieldName.alpha = 1
        textFieldEmail.alpha = 1
        textFieldPassword.alpha = 1

        requesting = false
        activityIndicator.stopAnimating()
    }

    // MARK: Keyboard Handlers
    override func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            visibleViewBottomConstraint.constant = keyboardSize.height
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        visibleViewBottomConstraint.constant = 0
    }

    // MARK: Request username
    fileprivate func signup() {
        startLoading()

        let name = textFieldName.text ?? ""
        let email = textFieldEmail.text ?? ""
        let password = textFieldPassword.text ?? ""

        AuthManager.signup(with: name, email, password) { [weak self] (response) in
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
                if let user = AuthManager.currentUser() {
                    if user.username != nil {
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        self?.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }
                }
            }
        }
    }

}

extension SignupViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !requesting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if requesting {
            return false
        }

        if textField == textFieldName {
            textFieldEmail.becomeFirstResponder()
        }

        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        }

        if textField == textFieldPassword {
            signup()
        }

        return true
    }
}
