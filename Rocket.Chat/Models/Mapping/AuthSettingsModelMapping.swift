//
//  AuthSettingsModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class AuthSettingsModelMapping: BaseModelMapping {
    typealias Model = AuthSettings

    // MARK: ModelMapping

    func map(_ instance: AuthSettings, values: JSON) {
        if instance.identifier == nil {
            instance.identifier = String.random()
        }

        instance.siteURL = objectForKey(object: values, key: "Site_Url")?.string
    }

    // MARK: Helpers

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        return object.array?.filter { obj in
            return obj["_id"].string == key
        }.first
    }
}
