//
//  CommandModelMapping.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

extension Command: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        self.command = values["command"].stringValue
        self.clientOnly = values["clientOnly"].boolValue
        self.params = values["params"].stringValue
        self.desc = values["description"].stringValue
    }
}
