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
import OAuthSwift
import SwiftyJSON

final class AuthViewController: BaseViewController {

    internal var connecting = false
    var serverURL: URL!
    var serverPublicSettings: AuthSettings?
    var temporary2FACode: String?

    var oauthSwift: OAuth2Swift?
    var loginServicesToken: NotificationToken?

    @IBOutlet weak var viewFields: UIView! {
        didSet {
            viewFields.layer.cornerRadius = 4
            viewFields.layer.borderColor = UIColor.RCLightGray().cgColor
            viewFields.layer.borderWidth = 0.5
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

    @IBOutlet weak var authButtonsStackView: UIStackView!
    var customAuthButtons = [String: UIButton]()
    var loginService: LoginService?
    var loginCredentialToken: String?
    var loginCredentialSecret: String?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = serverURL.host

        self.updateAuthenticationMethods()
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

                let alert = UIAlertController(
                    title: localized("error.socket.default_error_title"),
                    message: error["message"]?.string ?? localized("error.socket.default_error_message"),
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }

            return
        }

        API.shared.fetch(MeRequest()) { [weak self] result in
            self?.stopLoading()
            if let user = result?.user {
                if user.username != nil {

                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)

                        let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let controller = storyboardChat.instantiateInitialViewController()
                        let application = UIApplication.shared

                        if let window = application.windows.first {
                            window.rootViewController = controller
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }
                }
            }
        }
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
    }

    func stopLoading() {
        DispatchQueue.main.async(execute: {
            self.textFieldUsername.alpha = 1
            self.textFieldPassword.alpha = 1
            self.activityIndicator.stopAnimating()
            self.buttonAuthenticateGoogle.isEnabled = true
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
        self.loginServicesToken = LoginServiceManager.observe(block: updateLoginServices)

        LoginServiceManager.subscribe()
    }

    @objc func loginServiceButtonDidPress(_ button: UIButton) {
        guard let service = customAuthButtons.filter({ $0.value == button }).keys.first else { return }
        guard let loginService = LoginService.find(service: service) else { return }
        guard let host = loginService.serverURL, !host.isEmpty else { return }
        guard let clientId = loginService.clientId else { return }
        guard let authorizePath = loginService.authorizePath else { return }
        guard let tokenPath = loginService.tokenPath else { return }
        guard let callbackURL = URL(string: "https://\(serverURL.host ?? "")/_oauth/\(service)") else { return }

        oauthSwift = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: "3l9YH_Ser-7EN2s2qSfniu9V3vVjhg0AI7gvF9-BLWx",
            authorizeUrl: "\(host)\(authorizePath)",
            accessTokenUrl: "\(host)\(tokenPath)",
            responseType: "token"
        )

        guard let oauthSwift = oauthSwift else { return }

        let handler = WebViewController()
        oauthSwift.removeCallbackNotificationObserver()
        handler.targetURL = URL(string: "\(host)\(authorizePath)")
        handler.viewDidLoad()
        navigationController?.pushViewController(handler, animated: true)
        handler.didNavigate = { url in
            guard let url = url else { return false }
            if url.host == callbackURL.host && url.path == callbackURL.path, let fragment = url.fragment {
                let fragmentJSON = JSON(parseJSON: NSString(string: fragment).removingPercentEncoding ?? "")
                self.loginCredentialToken = fragmentJSON["credentialToken"].string
                self.loginCredentialSecret = fragmentJSON["credentialSecret"].string
                OAuthSwift.handle(url: url)
                return true
            }
            return false
        }
        oauthSwift.authorizeURLHandler = handler

        let state = "{\"loginStyle\":\"popup\",\"credentialToken\":\"\(String.random(40))\",\"isCordova\":true}".base64Encoded()
        let handle = oauthSwift.authorize(withCallbackURL: callbackURL, scope: loginService.scope ?? "",
                                          state: state ?? "", success: loginServiceSuccess, failure: loginServiceFailure)
        self.loginService = loginService
    }

    func updateLoginServices(changes: RealmCollectionChange<Results<LoginService>>) {
        switch changes {
        case .update(let res, let deletions, let insertions, _ /*let modifications*/):
            insertions.map { res[$0] }.forEach {
                guard $0.custom, !($0.serverURL?.isEmpty ?? true) else { return }

                let button = UIButton()
                button.layer.cornerRadius = 3
                button.setTitle($0.buttonLabelText ?? "", for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .black
                button.addTarget(self, action: #selector(loginServiceButtonDidPress(_:)), for: .touchUpInside)

                authButtonsStackView.addArrangedSubview(button)

                customAuthButtons[$0.service ?? ""] = button
            }

            deletions.map { res[$0] }.forEach {
                guard $0.custom else { return }
                guard let button = self.customAuthButtons[$0.identifier ?? ""] else { return }

                authButtonsStackView.removeArrangedSubview(button)

                customAuthButtons.removeValue(forKey: $0.identifier ?? "")
            }
        default:
            break
        }
    }

    func loginServiceSuccess(_ credential: OAuthSwiftCredential, _ response: OAuthSwiftResponse?, _ parameters: OAuthSwift.Parameters) {
        guard let loginService = self.loginService, let service = loginService.service, let scope = loginService.scope else { return }
        guard let loginToken = self.loginCredentialToken else { return }
        guard let loginSecret = self.loginCredentialSecret else { return }
        let params = [
            "oauth": [
                "credentialToken": loginToken,
                "credentialSecret": loginSecret
                ] as [String: Any]
            ]

        AuthManager.auth(params: params, completion: self.handleAuthenticationResponse)
    }

    func loginServiceFailure(_ error: OAuthSwiftError) {
        alert(title: "Error", message: ((error.errorUserInfo[NSLocalizedDescriptionKey] ?? "") as? String) ?? "")
    }
}
