//
//  LoginTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {

    internal let createAccountRow: Int = 5

    @IBOutlet weak var loginButton: StyledButton!
    @IBOutlet weak var textFieldUsername: StyledTextField!
    @IBOutlet weak var textFieldPassword: StyledTextField!
    @IBOutlet weak var forgotPasswordCell: UITableViewCell!
    @IBOutlet weak var createAccountButton: UIButton! {
        didSet {
            createAccountButton.titleLabel?.numberOfLines = 0

            let suffix = NSAttributedString(string: "Don't have an account?", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13, weight: .regular), NSAttributedStringKey.foregroundColor: UIColor.RCTextFieldGray()]) // TODO: Localize
            let createAccount = NSAttributedString(string: "\nCreate an Account", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedStringKey.foregroundColor: UIColor.RCSkyBlue()])
            let combinedString = NSMutableAttributedString(attributedString: suffix)
            combinedString.append(createAccount)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 1
            paragraphStyle.alignment = .center

            let combinationRange = NSRange(location: 0, length: combinedString.length)
            combinedString.addAttributes([NSAttributedStringKey.paragraphStyle: paragraphStyle], range: combinationRange)

            createAccountButton.setAttributedTitle(combinedString, for: .normal)
        }
    }

    var heightForSignUpRow: CGFloat {
        let forgotPasswordY = forgotPasswordCell.frame.origin.y
        let forgotPasswordHeight = forgotPasswordCell.frame.height
        var safeAreaInsets: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaInsets = tableView.safeAreaInsets.top + tableView.safeAreaInsets.bottom
        } else {
            safeAreaInsets = tableView.contentInset.top
        }

        let contentSize = forgotPasswordY + forgotPasswordHeight + safeAreaInsets

        return UIScreen.main.bounds.height - contentSize
    }

    var serverVersion: Version?
    var serverURL: URL!
    var serverPublicSettings: AuthSettings?
    var temporary2FACode: String?

    var api: API? {
        guard
            let serverURL = serverURL,
            let serverVersion = serverVersion
        else {
                return nil
        }

        return API(host: serverURL, version: serverVersion)
    }

    var shouldShowCreateAccount = false
    var isKeyboardAppearing = false
    var isRequesting = false

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if shouldShowCreateAccount {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillAppear(_:)),
                name: NSNotification.Name.UIKeyboardWillShow,
                object: nil
            )

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillDisappear(_:)),
                name: NSNotification.Name.UIKeyboardWillHide,
                object: nil
            )
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let nav = navigationController as? BaseNavigationController {
            nav.setGrayTheme()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Keyboard Management

    @objc func keyboardWillAppear(_ notification: Notification) {
        isKeyboardAppearing = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @objc func keyboardWillDisappear(_ notification: Notification) {
        isKeyboardAppearing = false
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: Actions

    @IBAction func forgotPasswordPressed(_ sender: UIButton) {
        let alert = UIAlertController(
            title: localized("auth.forgot_password.title"),
            message: localized("auth.forgot_password.message"),
            preferredStyle: .alert
        )

        let sendAction = UIAlertAction(title: localized("Send"), style: .default, handler: { _ in
            guard let text = alert.textFields?.first?.text else { return }

            AuthManager.sendForgotPassword(email: text, completion: { result in
                guard !result.isError() else {
                    Alert(
                        title: localized("auth.forgot_password.title"),
                        message: localized("error.socket.default_error.message")
                    ).present()
                    return
                }

                Alert(
                    title: localized("auth.forgot_password.title"),
                    message: localized("auth.forgot_password.success")
                ).present()
            })
        })

        sendAction.isEnabled = false

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "john.appleseed@apple.com"
            textField.textContentType = UITextContentType.emailAddress
            textField.keyboardType = .emailAddress

            _ = NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                sendAction.isEnabled = textField.text?.isValidEmail ?? false
            }
        })

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
        alert.addAction(sendAction)
        present(alert, animated: true)
    }

    @IBAction func didPressedLoginButton() {
        guard !isRequesting else {
            return
        }

        authenticateWithUsernameOrEmail()
    }

    func authenticateWithUsernameOrEmail() {
        let email = textFieldUsername.text ?? ""
        let password = textFieldPassword.text ?? ""

        startLoading()

        if serverPublicSettings?.isLDAPAuthenticationEnabled ?? false {
            let params = [
                "ldap": true,
                "username": email,
                "ldapPass": password,
                "ldapOptions": []
            ] as [String: Any]

            AuthManager.auth(params: params, completion: self.handleAuthenticationResponse)
        } else {
            AuthManager.auth(email, password: password, completion: self.handleAuthenticationResponse)
        }
    }

    func startLoading() {
        loginButton.startLoading()
        navigationItem.hidesBackButton = true
        forgotPasswordCell.isUserInteractionEnabled = false
        createAccountButton.isEnabled = false
    }

    func stopLoading() {
        loginButton.stopLoading()
        navigationItem.hidesBackButton = false
        forgotPasswordCell.isUserInteractionEnabled = true
        createAccountButton.isEnabled = true
    }

}

extension LoginTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == createAccountRow && !shouldShowCreateAccount {
            return 0
        }

        if indexPath.row == createAccountRow && !isKeyboardAppearing {
            return heightForSignUpRow
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
