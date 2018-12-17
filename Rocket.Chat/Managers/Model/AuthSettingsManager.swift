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
