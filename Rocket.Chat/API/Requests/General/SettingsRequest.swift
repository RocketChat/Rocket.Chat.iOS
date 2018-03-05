//
//  SettingsRequest.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/settings/get/

import SwiftyJSON

typealias SettingsResult = APIResult<SettingsRequest>

class SettingsRequest: APIRequest {
    let path = "/api/v1/settings"
}

extension APIResult where T == SettingsRequest {
    var settings: [Setting]? {
        return raw?["settings"].arrayValue.map {
            let setting = Setting()
            setting.map($0, realm: nil)
            return setting
            }.flatMap { $0 }
    }
}
