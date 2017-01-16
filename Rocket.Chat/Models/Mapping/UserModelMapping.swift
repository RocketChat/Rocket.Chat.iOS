//
//  UserModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class UserModelMapping: BaseModelMapping {
    typealias Model = User

    static func map(_ instance: User, values: JSON) {
        if instance.identifier == nil {
            instance.identifier = values["_id"].string
        }

        if let username = values["username"].string {
            instance.username = username
        }

        if let status = values["status"].string {
            instance.status = UserStatus(rawValue: status) ?? .offline
        }
    }
}
