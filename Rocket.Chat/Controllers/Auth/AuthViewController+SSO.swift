//
//  AuthViewController+SSO.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension AuthViewController {
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
}
