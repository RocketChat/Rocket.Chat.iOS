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
        }

        API.current()?.fetch(MeRequest()) { response in
            switch response {
            case .resource(let resource):
                SocketManager.removeConnectionHandler(token: self.socketHandlerToken)

                if let user = resource.user {
                    if user.username != nil {
                        self.dismiss(animated: true, completion: nil)
                        AppManager.reloadApp()
                    } else {
                        self.performSegue(withIdentifier: "RequestUsername", sender: nil)
                    }
                } else {
                    self.stopLoading()
                    Alert(key: "error.socket.default_error").present()
                }
            case .error:
                self.stopLoading()
            }
        }
    }
}
