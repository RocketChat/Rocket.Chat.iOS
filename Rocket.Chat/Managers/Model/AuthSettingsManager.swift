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

    static func updatePublicSettings(serverVersion: Version? = nil, apiHost: URL? = nil, _ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings>) {
        let api: API?
        if let apiHost = apiHost {
            if let serverVersion = serverVersion {
                api = API(host: apiHost, version: serverVersion)
            } else {
                api = API(host: apiHost)
            }
        } else {
            api = API.current()
        }

        let currentRealm = Realm.current
        let options = APIRequestOptions.paginated(count: 0, offset: 0)
        api?.fetch(PublicSettingsRequest(), options: options) { response in
            switch response {
            case .resource(let resource):
                guard resource.success else {
                    completion(nil)
                    return
                }

                currentRealm?.execute({ realm in
                    let settings = resource.authSettings
                    realm.add(settings, update: true)

                    if let auth = AuthManager.isAuthenticated(realm: realm) {
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
            case .error(let error):
                switch error {
                case .version: websocketUpdatePublicSettings(currentRealm, auth, completion: completion)
                default: completion(nil)
                }
            }
        }
    }

    private static func websocketUpdatePublicSettings(_ realm: Realm?, _ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings>) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
        ] as [String: Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(nil)
                return
            }

            realm?.execute({ realm in
                let settings = AuthManager.isAuthenticated(realm: realm)?.settings ?? AuthSettings()
                settings.map(response.result["result"], realm: realm)
                realm.add(settings, update: true)

                if let auth = AuthManager.isAuthenticated(realm: realm) {
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
