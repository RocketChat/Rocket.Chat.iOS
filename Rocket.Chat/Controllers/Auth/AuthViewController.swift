//
//  AuthViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import OnePasswordExtension
import RealmSwift

final class AuthViewController: BaseViewController {

    internal var connecting = false

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

    let socketHandlerToken = String.random(5)

    var loginServicesToken: NotificationToken?

    @IBOutlet weak var viewFieldsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewFields: UIView! {
        didSet {
            viewFields.layer.cornerRadius = 4
            viewFields.layer.borderColor = UIColor.RCLightGray().cgColor
            viewFields.layer.borderWidth = 0.5
        }
    }

    var hideViewFields: Bool = false {
        didSet {
            if hideViewFields {
                viewFields.isHidden = true
                viewFieldsHeightConstraint.constant = 0
            } else {
                viewFields.isHidden = false
                viewFieldsHeightConstraint.constant = 100
            }
        }
    }

    @IBOutlet weak var onePasswordButton: UIButton! {
        didSet {
            onePasswordButton.isHidden = !OnePasswordExtension.shared().isAppExtensionAvailable()
        }
    }

    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var visibleViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var buttonRegister: UIButton! {
        didSet {
            buttonRegister.setTitle(localized("auth.login.buttonRegister"), for: .normal)
        }
    }

    @IBOutlet weak var buttonResetPassword: UIButton! {
        didSet {
            buttonResetPassword.setTitle(localized("auth.login.buttonResetPassword"), for: .normal)
        }
    }

    @IBOutlet weak var labelProceedingAgreeing: UILabel! {
        didSet {
            labelProceedingAgreeing.text = localized("auth.login.agree_label")
        }
    }

    @IBOutlet weak var buttonTermsOfService: UIButton! {
        didSet {
            buttonTermsOfService.setTitle(localized("auth.login.agree_termsofservice"), for: .normal)
        }
    }

    @IBOutlet weak var labelAnd: UILabel! {
        didSet {
            labelAnd.text = localized("auth.login.agree_and")
        }
    }

    @IBOutlet weak var buttonPrivacy: UIButton! {
        didSet {
            buttonPrivacy.setTitle(localized("auth.login.agree_privacypolicy"), for: .normal)
        }
    }

    @IBOutlet weak var authButtonsStackView: UIStackView!
    var customAuthButtons = [String: UIButton]()

    deinit {
        loginServicesToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = serverURL.host

        guard let settings = serverPublicSettings else {
            return
        }

        if !settings.isUsernameEmailAuthenticationEnabled {
            buttonRegister.isHidden = true
        } else {
            buttonRegister.isHidden = settings.registrationForm != .isPublic
        }

        hideViewFields = !settings.isUsernameEmailAuthenticationEnabled
        buttonResetPassword.isHidden = !settings.isPasswordResetEnabled

        updateFieldsPlaceholders()
        updateAuthenticationMethods()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupLoginServices()

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

        if !connecting {
            textFieldUsername.becomeFirstResponder()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TwoFactor" {
            if let controller = segue.destination as? TwoFactorAuthenticationViewController {
                controller.username = textFieldUsername.text ?? ""
                controller.password = textFieldPassword.text ?? ""
                controller.token = temporary2FACode ?? ""
            }
        }
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

    // MARK: Loaders

    func startLoading() {
        textFieldUsername.alpha = 0.5
        textFieldPassword.alpha = 0.5
        connecting = true
        activityIndicator.startAnimating()
        textFieldUsername.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        customAuthButtons.forEach { _, button in button.isEnabled = false }
        navigationItem.hidesBackButton = true
    }

    func stopLoading() {
        DispatchQueue.main.async(execute: {
            self.textFieldUsername.alpha = 1
            self.textFieldPassword.alpha = 1
            self.activityIndicator.stopAnimating()
            self.customAuthButtons.forEach { _, button in button.isEnabled = true }
            self.navigationItem.hidesBackButton = false
        })

        connecting = false
    }

    // MARK: IBAction

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

    func authenticateWithDeepLinkCredentials(_ credentials: DeepLinkCredentials) {
        startLoading()
        AuthManager.auth(token: credentials.token, completion: self.handleAuthenticationResponse)
    }

    @objc func loginServiceButtonDidPress(_ button: UIButton) {
        guard
            let service = customAuthButtons.filter({ $0.value == button }).keys.first,
            let realm = Realm.current,
            let loginService = LoginService.find(service: service, realm: realm)
        else {
            return
        }

        switch loginService.type {
        case .cas:
            presentCASViewController(for: loginService)
        case .saml:
            presentSAMLViewController(for: loginService)
        default:
            presentOAuthViewController(for: loginService)
        }

    }

    @IBAction func buttonTermsDidPressed(_ sender: Any) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.serverURL.host
        components.path = self.serverURL.path

        if var newURL = components.url {
            newURL = newURL.appendingPathComponent("terms-of-service")

            let controller = SFSafariViewController(url: newURL)
            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func buttonPolicyDidPressed(_ sender: Any) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.serverURL.host
        components.path = self.serverURL.path

        if var newURL = components.url {
            newURL = newURL.appendingPathComponent("privacy-policy")

            let controller = SFSafariViewController(url: newURL)
            present(controller, animated: true, completion: nil)
        }
    }

    @IBAction func buttonOnePasswordDidPressed(_ sender: Any) {
        let siteURL = serverPublicSettings?.siteURL ?? ""
        OnePasswordExtension.shared().findLogin(forURLString: siteURL, for: self, sender: sender) { [weak self] (login, _) in
            if login == nil {
                return
            }

            self?.textFieldUsername.text = login?[AppExtensionUsernameKey] as? String
            self?.textFieldPassword.text = login?[AppExtensionPasswordKey] as? String
            self?.temporary2FACode = login?[AppExtensionTOTPKey] as? String
            self?.authenticateWithUsernameOrEmail()
        }
    }

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
}

extension AuthViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !connecting
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if connecting {
            return false
        }

        if textField == textFieldUsername {
            textFieldPassword.becomeFirstResponder()
        }

        if textField == textFieldPassword {
            authenticateWithUsernameOrEmail()
        }

        return true
    }
}
