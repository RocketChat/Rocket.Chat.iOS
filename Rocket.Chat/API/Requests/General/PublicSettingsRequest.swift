//
//  PublicSettingsRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 02/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
typealias PublicSettingsResult = APIResult<PublicSettingsRequest>

class PublicSettingsRequest: APIRequest {
    let requiredVersion = Version(0, 62, 2)
    let path = "/api/v1/settings.public"
}

extension APIResult where T == PublicSettingsRequest {
    var authSettings: AuthSettings {
        let authSettings = AuthSettings()

        if let authSettingsRaw = raw?["settings"] {
            authSettings.map(authSettingsRaw, realm: nil)
        }

        return authSettings
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }

    var errorMessage: String? {
        return raw?["error"].string
    }
}
