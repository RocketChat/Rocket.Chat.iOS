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

    func setupLoginServices() {
        guard shouldRetrieveLoginServices else {
            return
        }

        if let objects = Realm.current?.objects(LoginService.self) {
            loginServices = objects.map({ $0 })
        }

        loginServicesToken?.invalidate()
        loginServicesToken = LoginServiceManager.observe { [weak self] changes in
            self?.updateLoginServices(changes: changes)
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

        startLoading()
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

        startLoading()
        navigationController?.pushViewController(controller, animated: true)
        return
    }

    func updateLoginServices(changes: RealmCollectionChange<Results<LoginService>>) {
        switch changes {
        case .update(let res, let deletions, let insertions, let modifications):
            self.loginServices.append(contentsOf: insertions.map { res[$0] }.compactMap {
                return ($0.isValid && $0.service != nil) ? $0 : nil
            })

            modifications.map { res[$0] }.forEach {
                guard let index = self.loginServices.index(of: $0) else {
                    return
                }

                self.loginServices[index] = $0
            }

            deletions.map { res[$0] }.forEach {
                guard let index = self.loginServices.index(of: $0) else {
                    return
                }

                self.loginServices.remove(at: index)
            }
        default: break
        }
    }
}
