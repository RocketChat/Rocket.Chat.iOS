//
//  AuthTableViewControllerAuthenticationHandler.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension AuthTableViewController {
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

            if let publicSettings = serverPublicSettings {
                AuthSettingsManager.persistPublicSettings(settings: publicSettings)
            }

            if let realm = Realm.current, let auth = AuthManager.isAuthenticated(realm: realm), let version = serverVersion {
                try? realm.write {
                    auth.serverVersion = version.description
                }
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
                if let token = self?.socketHandlerToken {
                    SocketManager.removeConnectionHandler(token: token)
                }

                if let user = resource.user {
                    let realm = Realm.current
                    try? realm?.write {
                        realm?.add(user, update: true)
                    }

                    if user.username != nil {
                        self?.dismiss(animated: true, completion: nil)
                        AppManager.reloadApp()
                    } else {
                        self?.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }
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
