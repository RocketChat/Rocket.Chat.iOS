//
//  PermissionModelMapping.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Permission: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].string
        }

        if let roles = values["roles"].array?.flatMap({ $0.string }) {
            self.roles.removeAll()
            self.roles.append(contentsOf: roles)
        }
    }
}
