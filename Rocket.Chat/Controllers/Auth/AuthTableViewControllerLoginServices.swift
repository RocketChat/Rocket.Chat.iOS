//
//  AuthTableViewControllerLoginServices.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

// MARK: Login Services

extension AuthTableViewController {

    func updateAuthenticationMethods() {
        guard let settings = serverPublicSettings else { return }

        if settings.isGoogleAuthenticationEnabled {
            addOAuthButton(for: .google)
        }

        if settings.isFacebookAuthenticationEnabled {
            addOAuthButton(for: .facebook)
        }

        if settings.isGitHubAuthenticationEnabled {
            addOAuthButton(for: .github)
        }

        if settings.isGitLabAuthenticationEnabled {
            addOAuthButton(for: .gitlab(url: settings.gitlabUrl))
        }

        if settings.isLinkedInAuthenticationEnabled {
            addOAuthButton(for: .linkedin)
        }

        if settings.isWordPressAuthenticationEnabled {
            addOAuthButton(for: .wordpress)
        }

        if settings.isCASEnabled {
            addOAuthButton(for: .cas)
        }
    }

    func setupLoginServices() {
//        loginServicesToken?.invalidate()
//
//        loginServicesToken = LoginServiceManager.observe { [weak self] changes in
//            self?.updateLoginServices(changes: changes)
//        }
//
//        api?.client(InfoClient.self).fetchLoginServices()
    }

    func presentOAuthViewController(for loginService: LoginService) {
        OAuthManager.authorize(loginService: loginService, at: serverURL, viewController: self, success: { [weak self] credentials in
            guard let strongSelf = self else { return }
//            strongSelf.startLoading()
            // TODO: Start loading for OAuth

            AuthManager.auth(credentials: credentials, completion: strongSelf.handleAuthenticationResponse)
            }, failure: { [weak self] in
                self?.alert(
                    title: localized("alert.login_service_error.title"),
                    message: localized("alert.login_service_error.message")
                )

//                self?.stopLoading()
                // TODO: Stop loading for OAuth
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
//            self?.stopLoading()
            // TODO: Stop loading for OAuth
        })

//        startLoading()
        // TODO: Start loading for OAuth
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
//            self?.stopLoading()
            // TODO: Stop loading for OAuth
        })

//        startLoading()
        // TODO: Start loading for OAuth
        navigationController?.pushViewController(controller, animated: true)
        return
    }

    func addOAuthButton(for loginService: LoginService) {
        guard let service = loginService.service else { return }

//        let button = customAuthButtons[service] ?? UIButton()
        let button = UIButton() // TODO: Fix it

        switch loginService.type {
        case .google: button.setImage(#imageLiteral(resourceName: "google"), for: .normal)
        case .facebook: button.setImage(#imageLiteral(resourceName: "facebook"), for: .normal)
        case .github: button.setImage(#imageLiteral(resourceName: "github"), for: .normal)
        case .gitlab: button.setImage(#imageLiteral(resourceName: "gitlab"), for: .normal)
        case .linkedin: button.setImage(#imageLiteral(resourceName: "linkedin"), for: .normal)
        case .wordpress: button.setImage(#imageLiteral(resourceName: "wordpress"), for: .normal)
        default: button.setTitle(loginService.buttonLabelText ?? "", for: .normal)
        }

        button.layer.cornerRadius = 3
        button.titleLabel?.font = .boldSystemFont(ofSize: 17.0)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor(hex: loginService.buttonLabelColor), for: .normal)
        button.backgroundColor = UIColor(hex: loginService.buttonColor)

//        if !authButtonsStackView.subviews.contains(button) {
//            authButtonsStackView.addArrangedSubview(button)
//            button.addTarget(self, action: #selector(loginServiceButtonDidPress(_:)), for: .touchUpInside)
//            customAuthButtons[service] = button
//        }
    }

    func updateLoginServices(changes: RealmCollectionChange<Results<LoginService>>) {
        switch changes {
        case .update(let res, let deletions, let insertions, let modifications):
            let loginServices = insertions.map { res[$0] }.compactMap {
                return ($0.isValid && $0.service != nil) ? $0 : nil
            }

//            self.loginServices = loginServices
            self.loginServices.append(contentsOf: loginServices)

            modifications.map { res[$0] }.forEach {
                guard
                    let identifier = $0.identifier
//                    let button = customAuthButtons[identifier]
                    // TODO: Fixit
                    else {
                        return
                }

                let button = UIButton() // TODO: Fixit
                button.setTitle($0.buttonLabelText ?? "", for: .normal)
                button.setTitleColor(UIColor(hex: $0.buttonLabelColor), for: .normal)
                button.backgroundColor = UIColor(hex: $0.buttonColor)
            }

            deletions.map { res[$0] }.forEach {
                guard
                    $0.custom,
                    let identifier = $0.identifier
//                    let button = customAuthButtons[identifier]
                    else {
                        return
                }

//                authButtonsStackView.removeArrangedSubview(button)
//                customAuthButtons.removeValue(forKey: identifier)
            }
        default: break
        }
    }
}
