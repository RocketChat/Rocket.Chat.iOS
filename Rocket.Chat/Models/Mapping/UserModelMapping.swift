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

        if let utcOffset = values["utcOffset"].double {
            self.utcOffset = utcOffset
        }

        if let emailsRaw = values["emails"].array {
            let emails = emailsRaw.compactMap { emailRaw -> Email? in
                let email = Email(value: [
                    "email": emailRaw["address"].stringValue,
                    "verified": emailRaw["verified"].boolValue
                    ])

                guard !email.email.isEmpty else { return nil }

                return email
            }

            self.emails.removeAll()
            self.emails.append(contentsOf: emails)
        }

        mapRoles(values["roles"])
    }

    func mapRoles(_ values: JSON) {
        if let roles = values.array?.compactMap({ $0.string }) {
            self.roles.removeAll()
            self.roles.append(contentsOf: roles)
        }
    }
}
