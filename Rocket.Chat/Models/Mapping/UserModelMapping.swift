//
//  UserModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension User: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].string
        }

        if let username = values["username"].string {
            self.username = username
        }

        if let name = values["name"].string {
            self.name = name
        }

        if let status = values["status"].string {
            self.status = UserStatus(rawValue: status) ?? .offline
        }
    }
}
