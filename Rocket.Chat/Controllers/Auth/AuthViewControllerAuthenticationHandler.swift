//
//  AuthViewControllerAuthenticationHandler.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension AuthViewController {
    internal func handleAuthenticationResponse(_ response: LoginResponse) {
        if case let .resource(resource) = response, let error = resource.error {
            stopLoading()

            switch error.lowercased() {
            case "totp-required":
                return performSegue(withIdentifier: "TwoFactor", sender: nil)
            case "unauthorized":
                return Alert(key: "error.login_unauthorized").present()
            default:
                return Alert(key: "error.login").present()
            }
        }

        if let publicSettings = serverPublicSettings {
            AuthSettingsManager.persistPublicSettings(settings: publicSettings)
        }

        API.current()?.fetch(MeRequest()) { [weak self] response in
            switch response {
            case .resource(let resource):
                guard let strongSelf = self else { return }

                SocketManager.removeConnectionHandler(token: strongSelf.socketHandlerToken)

                if let user = resource.user {
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
