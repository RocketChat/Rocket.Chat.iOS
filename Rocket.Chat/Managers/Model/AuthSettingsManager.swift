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

            Realm.executeOnMainThread({ realm in
                let settings = AuthManager.isAuthenticated()?.settings ?? AuthSettings()
                var serverId: String?
                var videoChatPrefix: String?
                var videoChatServerUrl: String?

                if let lst = response.result["result"].array, lst.count > 0 {
                    for item in lst {
                        if item["_id"] == "uniqueID" {
                            serverId = item["value"].stringValue
                        } else if item["_id"] == "Jitsi_URL_Room_Prefix" {
                            videoChatPrefix = item["value"].stringValue
                        } else if item["_id"] == "Jitsi_Domain" {
                            videoChatServerUrl = item["value"].stringValue
                        }

                        if serverId != nil && videoChatPrefix != nil {
                            break
                        }
                    }
                    settings.serverId = serverId
                    settings.videoChatPrefix = videoChatPrefix
                    settings.videoChatServerUrl = videoChatServerUrl
                    print("ServerID: \(settings.serverId ?? "---") | Prefix: \(settings.videoChatPrefix ?? "---")")
                }
                settings.map(response.result["result"], realm: realm)
                realm.add(settings, update: true)

                if let auth = AuthManager.isAuthenticated() {
                    auth.settings = settings
                    realm.add(auth, update: true)
                }

                let unmanagedSettings = AuthSettings(value: settings)
                shared.internalSettings = unmanagedSettings
                ServerManager.updateServerInformation(from: unmanagedSettings)
                completion(unmanagedSettings)
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
