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
        self.roles.removeAll()
        if let roles = values["roles"].array?.flatMap({ $0.string }).flatMap({ Role(rawValue: $0) }) {
            self.roles.append(contentsOf: roles)
        }
    }
}
