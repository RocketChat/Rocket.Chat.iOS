//
//  MentionModelMapping.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Mention: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.username = values["username"].stringValue
    }
}
