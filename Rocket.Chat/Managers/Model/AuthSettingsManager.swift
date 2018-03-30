//
//  AuthSettingsManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 08/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class AuthSettingsManager {

    static let shared = AuthSettingsManager()
    static var settings: AuthSettings? { return shared.settings }

    internal var internalSettings: AuthSettings?
    var settings: AuthSettings? {
        set { }
        get {
            if internalSettings == nil {
                updateCachedSettings()
            }

            return internalSettings
        }
    }

    static func updatePublicSettings(_ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings>) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
        ] as [String: Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(nil)
                return
            }

            Realm.execute({ realm in
                let settings = AuthManager.isAuthenticated()?.settings ?? AuthSettings()
                settings.map(response.result["result"], realm: realm)
                realm.add(settings, update: true)

                if let auth = AuthManager.isAuthenticated() {
                    auth.settings = settings
                    realm.add(auth, update: true)
                }

                let unmanagedSettings = AuthSettings(value: settings)
                shared.internalSettings = unmanagedSettings

                DispatchQueue.main.async {
                    ServerManager.updateServerInformation(from: unmanagedSettings)
                    completion(unmanagedSettings)
                }
            })
        }
    }

    func updateCachedSettings() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let settings = auth.settings else { return }

        let unmanagedSettings = AuthSettings(value: settings)
        internalSettings = unmanagedSettings
    }

    func clearCachedSettings() {
        internalSettings = nil
    }

}
