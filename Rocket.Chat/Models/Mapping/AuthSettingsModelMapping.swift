//
//  AuthSettingsModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

extension AuthSettings: ModelMappeable {
    func map(_ values: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.siteURL = objectForKey(object: values, key: "Site_Url")?.string
    }

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        return object.array?.filter { obj in
            return obj["_id"].string == key
        }.first
    }
}
