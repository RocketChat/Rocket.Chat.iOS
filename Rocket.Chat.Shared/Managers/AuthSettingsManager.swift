//
//  AuthSettingsManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 08/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

public final class AuthSettingsManager: SocketManagerInjected, AuthManagerInjected {

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

    func updatePublicSettings(_ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings?>) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
            ] as [String : Any]

        socketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(nil)
                return
            }

            Realm.executeOnMainThread({ realm in
                let settings = self.authManager.isAuthenticated()?.settings ?? AuthSettings()
                settings.map(response.result["result"], realm: realm)
                realm.add(settings, update: true)

                if let auth = self.authManager.isAuthenticated() {
                    auth.settings = settings
                    realm.add(auth, update: true)
                }

                let unmanagedSettings = AuthSettings(value: settings)
                self.internalSettings = unmanagedSettings
                completion(unmanagedSettings)
            })
        }
    }

    func updateCachedSettings() {
        guard let auth = authManager.isAuthenticated() else { return }
        guard let settings = auth.settings else { return }

        let unmanagedSettings = AuthSettings(value: settings)
        internalSettings = unmanagedSettings
    }

    func clearCachedSettings() {
        internalSettings = nil
    }

}
