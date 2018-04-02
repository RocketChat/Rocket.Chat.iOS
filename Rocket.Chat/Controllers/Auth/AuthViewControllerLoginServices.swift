//
//  AuthViewControllerLoginSevices.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

// MARK: Login Services

extension AuthViewController {
    func updateFieldsPlaceholders() {
        guard let settings = self.serverPublicSettings else { return }

        if !(settings.emailOrUsernameFieldPlaceholder?.isEmpty ?? true) {
            self.textFieldUsername.placeholder = settings.emailOrUsernameFieldPlaceholder
        }

        if !(settings.passwordFieldPlaceholder?.isEmpty ?? true) {
            self.textFieldPassword.placeholder = settings.passwordFieldPlaceholder
        }
    }

    func updateAuthenticationMethods() {
        guard let settings = self.serverPublicSettings else { return }

        self.buttonAuthenticateGoogle.isHidden = !settings.isGoogleAuthenticationEnabled

        if settings.isFacebookAuthenticationEnabled {
            addOAuthButton(for: .facebook)
        }

        if settings.isGitHubAuthenticationEnabled {
            addOAuthButton(for: .github)
        }

        if settings.isGitLabAuthenticationEnabled {
            addOAuthButton(for: .gitlab)
        }

        if settings.isLinkedInAuthenticationEnabled {
            addOAuthButton(for: .linkedin)
        }

        if settings.isCASEnabled {
            addOAuthButton(for: .cas)
        }
    }

    func setupLoginServices() {
        self.loginServicesToken?.invalidate()

        self.loginServicesToken = LoginServiceManager.observe { [weak self] changes in
            self?.updateLoginServices(changes: changes)
        }

        LoginServiceManager.subscribe()
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
        case .facebook: button.setImage(#imageLiteral(resourceName: "facebook"), for: .normal)
        case .github: button.setImage(#imageLiteral(resourceName: "github"), for: .normal)
        case .gitlab: button.setImage(#imageLiteral(resourceName: "gitlab"), for: .normal)
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
