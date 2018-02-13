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

    var serverURL: URL!
    var serverPublicSettings: AuthSettings?
    var temporary2FACode: String?

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

    @IBOutlet weak var buttonAuthenticateGoogle: UIButton! {
        didSet {
            buttonAuthenticateGoogle.layer.cornerRadius = 3
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var buttonRegister: UIButton!
    @IBOutlet weak var buttonResetPassword: UIButton!

    @IBOutlet weak var authButtonsStackView: UIStackView!
    var customAuthButtons = [String: UIButton]()

    deinit {
        loginServicesToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = serverURL.host

        if let registrationForm = AuthSettingsManager.shared.settings?.registrationForm {
           buttonRegister.isHidden = registrationForm != .isPublic
        }

        hideViewFields = !(AuthSettingsManager.settings?.isUsernameEmailAuthenticationEnabled ?? true)
        buttonResetPassword.isHidden = !(AuthSettingsManager.settings?.isPasswordResetEnabled ?? true)

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

    // MARK: Authentication methods
    fileprivate func updateAuthenticationMethods() {
        guard let settings = self.serverPublicSettings else { return }
        self.buttonAuthenticateGoogle.isHidden = !settings.isGoogleAuthenticationEnabled

        if settings.isFacebookAuthenticationEnabled {
            addOAuthButton(for: .facebook)
        }

        if settings.isGitHubAuthenticationEnabled {
            addOAuthButton(for: .github)
        }

        if settings.isLinkedInAuthenticationEnabled {
            addOAuthButton(for: .linkedin)
        }

        if settings.isCASEnabled {
            addOAuthButton(for: .cas)
        }
    }

    internal func handleAuthenticationResponse(_ response: SocketResponse) {
        if response.isError() {
            stopLoading()

            if let error = response.result["error"].dictionary {
                // User is using 2FA
                if error["error"]?.string == "totp-required" {
                    performSegue(withIdentifier: "TwoFactor", sender: nil)
                    return
                }

                Alert(
                    key: "error.socket.default_error"
                ).present()
            }

            return
        }

        API.current()?.fetch(MeRequest(), succeeded: { [weak self] result in
            guard let strongSelf = self else { return }

            SocketManager.removeConnectionHandler(token: strongSelf.socketHandlerToken)

            if let user = result.user {
                if user.username != nil {

                    DispatchQueue.main.async {
                        strongSelf.dismiss(animated: true, completion: nil)
                        AppManager.reloadApp()
                    }
                } else {
                    DispatchQueue.main.async {
                        strongSelf.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }
                }
            }
        }, errored: { [weak self] _ in
            self?.stopLoading()
        })
    }

    // MARK: Loaders
    func startLoading() {
        textFieldUsername.alpha = 0.5
        textFieldPassword.alpha = 0.5
        connecting = true
        activityIndicator.startAnimating()
        textFieldUsername.resignFirstResponder()
        textFieldPassword.resignFirstResponder()
        buttonAuthenticateGoogle.isEnabled = false
        customAuthButtons.forEach { _, button in button.isEnabled = false }
        navigationItem.hidesBackButton = true
    }

    func stopLoading() {
        DispatchQueue.main.async(execute: {
            self.textFieldUsername.alpha = 1
            self.textFieldPassword.alpha = 1
            self.activityIndicator.stopAnimating()
            self.buttonAuthenticateGoogle.isEnabled = true
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

    @IBAction func buttonAuthenticateGoogleDidPressed(_ sender: Any) {
        authenticateWithGoogle()
    }

    @IBAction func buttonTermsDidPressed(_ sender: Any) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.serverURL.host

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

// MARK: Login Services

extension AuthViewController {

    func setupLoginServices() {
        self.loginServicesToken?.invalidate()

        self.loginServicesToken = LoginServiceManager.observe { [weak self] changes in
            self?.updateLoginServices(changes: changes)
        }

        LoginServiceManager.subscribe()
    }

    @objc func loginServiceButtonDidPress(_ button: UIButton) {
        guard
            let service = customAuthButtons.filter({ $0.value == button }).keys.first,
            let realm = Realm.shared,
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

    func presentOAuthViewController(for loginService: LoginService) {
        OAuthManager.authorize(loginService: loginService, at: serverURL, viewController: self, success: { [weak self] credentials in
            guard let strongSelf = self else { return }

            strongSelf.startLoading()
            AuthManager.auth(credentials: credentials, completion: strongSelf.handleAuthenticationResponse)
            }, failure: { [weak self] in
                self?.alert(
                    title: localized("alert.login_service_error.title"),
                    message: localized("alert.login_service_error.message")
                )

                self?.stopLoading()
        })
    }

    func presentCASViewController(for loginService: LoginService) {
        guard
            let loginUrlString = loginService.loginUrl,
            let loginUrl = URL(string: loginUrlString),
            let host = serverURL.host,
            let callbackUrl = URL(string: "https://\(host)/_cas/\(String.random(17))")
        else {
            return
        }

        let controller = CASViewController(loginUrl: loginUrl, callbackUrl: callbackUrl, success: {
            AuthManager.auth(casCredentialToken: $0, completion: self.handleAuthenticationResponse)
        }, failure: { [weak self] in
            self?.stopLoading()
        })

        self.startLoading()

        navigationController?.pushViewController(controller, animated: true)

        return
    }

    func presentSAMLViewController(for loginService: LoginService) {
        guard
            let provider = loginService.provider,
            let host = serverURL.host,
            let serverUrl = URL(string: "https://\(host)")
        else {
            return
        }

        let controller = SAMLViewController(serverUrl: serverUrl, provider: provider, success: {
            AuthManager.auth(samlCredentialToken: $0, completion: self.handleAuthenticationResponse)
        }, failure: { [weak self] in
            self?.stopLoading()
        })

        self.startLoading()

        navigationController?.pushViewController(controller, animated: true)

        return
    }

    func addOAuthButton(for loginService: LoginService) {
        guard let service = loginService.service else { return }

        let button = customAuthButtons[service] ?? UIButton()

        switch loginService.type {
        case .github: button.setImage(#imageLiteral(resourceName: "github"), for: .normal)
        case .facebook: button.setImage(#imageLiteral(resourceName: "facebook"), for: .normal)
        case .linkedin: button.setImage(#imageLiteral(resourceName: "linkedin"), for: .normal)
        default: button.setTitle(loginService.buttonLabelText ?? "", for: .normal)
        }

        button.layer.cornerRadius = 3
        button.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor(hex: loginService.buttonLabelColor), for: .normal)
        button.backgroundColor = UIColor(hex: loginService.buttonColor)

        if !authButtonsStackView.subviews.contains(button) {
            authButtonsStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(loginServiceButtonDidPress(_:)), for: .touchUpInside)
            customAuthButtons[service] = button
        }
    }

    func updateLoginServices(changes: RealmCollectionChange<Results<LoginService>>) {
        switch changes {
        case .update(let res, let deletions, let insertions, let modifications):
            insertions.map { res[$0] }.forEach {
                guard $0.isValid else { return }
                self.addOAuthButton(for: $0)
            }

            modifications.map { res[$0] }.forEach {
                guard
                    let identifier = $0.identifier,
                    let button = self.customAuthButtons[identifier]
                else {
                    return
                }

                button.setTitle($0.buttonLabelText ?? "", for: .normal)
                button.setTitleColor(UIColor(hex: $0.buttonLabelColor), for: .normal)
                button.backgroundColor = UIColor(hex: $0.buttonColor)
            }

            deletions.map { res[$0] }.forEach {
                guard
                    $0.custom,
                    let identifier = $0.identifier,
                    let button = self.customAuthButtons[identifier]
                else {
                    return
                }

                authButtonsStackView.removeArrangedSubview(button)
                customAuthButtons.removeValue(forKey: identifier)
            }
        default: break
        }
    }
}
extension AuthViewController: SocketConnectionHandler {

    func socketDidConnect(socket: SocketManager) { }
    func socketDidReturnError(socket: SocketManager, error: SocketError) { }

    func socketDidDisconnect(socket: SocketManager) {
        alert(title: localized("error.socket.default_error.title"), message: localized("error.socket.default_error.message")) { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }

}
