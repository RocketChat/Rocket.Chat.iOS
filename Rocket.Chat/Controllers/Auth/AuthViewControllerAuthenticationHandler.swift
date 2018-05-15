//
//  AuthViewControllerAuthenticationHandler.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension AuthViewController {
    internal func handleAuthenticationResponse(_ response: LoginResponse) {
        if case let .resource(resource) = response, let error = resource.error {
            DispatchQueue.main.async { [weak self] in
                self?.stopLoading()

                switch error.lowercased() {
                case "totp-required":
                    self?.performSegue(withIdentifier: "TwoFactor", sender: nil)
                case "unauthorized":
                    Alert(key: "error.login_unauthorized").present()
                default:
                    Alert(key: "error.login").present()
                }
            }
        }

        if let publicSettings = serverPublicSettings {
            AuthSettingsManager.persistPublicSettings(settings: publicSettings)
        }

        if let realm = Realm.current, let auth = AuthManager.isAuthenticated(realm: realm), let version = serverVersion {
            try? realm.write {
                auth.serverVersion = version.description
            }
        }

        API.current()?.fetch(MeRequest()) { [weak self] response in
            switch response {
            case .resource(let resource):
                if let token = self?.socketHandlerToken {
                    SocketManager.removeConnectionHandler(token: token)
                }

                if let user = resource.user {
                    if user.username != nil {
                        DispatchQueue.main.async { [weak self] in
                            self?.dismiss(animated: true, completion: nil)
                            AppManager.reloadApp()
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.performSegue(withIdentifier: "RequestUsername", sender: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.stopLoading()
                        Alert(key: "error.socket.default_error").present()
                    }
                }
            case .error:
                DispatchQueue.main.async { [weak self] in
                    self?.stopLoading()
                }
            }
        }
    }
}
