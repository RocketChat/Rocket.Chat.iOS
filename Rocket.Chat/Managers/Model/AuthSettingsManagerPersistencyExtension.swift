//
//  AuthSettingsManagerPersistencyExtension.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 14/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension AuthSettingsManager {

    static func persistPublicSettings(settings: AuthSettings, realm: Realm? = Realm.current, completion: (MessageCompletionObject<AuthSettings>)? = nil) {
        let unmanagedSettings = AuthSettings(value: settings)
        shared.internalSettings = unmanagedSettings

        realm?.execute({ realm in
            // Delete all the AuthSettings objects, since we don't
            // support multiple-server per database
            realm.delete(realm.objects(AuthSettings.self))
        })

        realm?.execute({ realm in
            realm.add(settings)

            if let auth = AuthManager.isAuthenticated(realm: realm) {
                auth.settings = settings
                realm.add(auth, update: true)
            }
        })

        ServerManager.updateServerInformation(from: unmanagedSettings)
        completion?(unmanagedSettings)
    }

    static func updatePublicSettings(
        serverVersion: Version? = nil,
        apiHost: URL? = nil,
        apiSSLCertificatePath: URL? = nil,
        apiSSLCertificatePassword: String = "",
        _ auth: Auth?,
        completion: (MessageCompletionObject<AuthSettings>)? = nil) {

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

        if let certificatePathURL = apiSSLCertificatePath {
            api?.sslCertificatePath = certificatePathURL
            api?.sslCertificatePassword = apiSSLCertificatePassword
        }

        let realm = Realm.current
        let options: APIRequestOptionSet = [.paginated(count: 0, offset: 0)]
        api?.fetch(PublicSettingsRequest(), options: options) { response in
            switch response {
            case .resource(let resource):
                guard resource.success else {
                    completion?(nil)
                    return
                }

                persistPublicSettings(settings: resource.authSettings, realm: realm, completion: completion)
            case .error(let error):
                switch error {
                case .version: websocketUpdatePublicSettings(realm, auth, completion: completion)
                default: completion?(nil)
                }
            }
        }
    }

    private static func websocketUpdatePublicSettings(_ realm: Realm?, _ auth: Auth?, completion: (MessageCompletionObject<AuthSettings>)? = nil) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
            ] as [String: Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                completion?(nil)
                return
            }

            let settings = AuthSettings()
            settings.map(response.result["result"], realm: realm)
            persistPublicSettings(settings: settings, realm: realm, completion: completion)
        }
    }

}
