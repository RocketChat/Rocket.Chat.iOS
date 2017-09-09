//
//  ChannelModelMapping.swift
//  Rocket.Chat
//
//  Created by Matheus Martins on 9/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Channel: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.name = values["name"].string ?? ""
    }
}
