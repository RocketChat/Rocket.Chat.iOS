//
//  AuthSettings.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 06/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

final class AuthSettings: BaseModel {
    dynamic var siteURL: String?

    // MARK: ModelMapping

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        return object.array?.filter { obj in
            return obj["_id"].string == key
        }.first
    }

    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.siteURL = objectForKey(object: dict, key: "Site_Url")?.string

    }
}
