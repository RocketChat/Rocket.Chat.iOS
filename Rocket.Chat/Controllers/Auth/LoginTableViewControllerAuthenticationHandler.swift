//
//  LoginTableViewControllerAuthenticationHandler.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 13/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import RealmSwift

extension LoginTableViewController {
    internal func handleAuthenticationResponse(_ response: LoginResponse) {
        switch response {
        case .resource(let resource):
            guard let error = resource.error else { break }

            stopLoading()

            switch error.lowercased() {
            case "totp-required":
                performSegue(withIdentifier: "TwoFactor", sender: nil)
            case "unauthorized":
                Alert(key: "error.login_unauthorized").present()
                return
            default:
                Alert(key: "error.login").present()
                return
            }

            if let realm = Realm.current, let auth = AuthManager.isAuthenticated(realm: realm), let version = serverVersion {
                realm.execute({ _ in
                    auth.serverVersion = version.description
                })
            }
        case .error(let error):
            stopLoading()
            alert(title: localized("error.login.title"), message: error.description)
        }

        performMeRequest()
    }

    internal func performMeRequest() {
        API.current()?.fetch(MeRequest()) { [weak self] response in
            switch response {
            case .resource(let resource):
                self?.stopLoading()

                if let user = resource.user {
                    let realm = Realm.current
                    Realm.executeOnMainThread(realm: realm) { realm in
                        realm.add(user, update: true)
                    }
                    if user.username != nil {
                        self?.dismiss(animated: true, completion: nil)
                        AppManager.reloadApp()
                    } else {
                        self?.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }

                    AnalyticsManager.log(event: .login)
                } else {
                    self?.stopLoading()
                    Alert(key: "error.socket.default_error").present()
                }
            case .error:
                self?.stopLoading()
            }
        }
    }
}
