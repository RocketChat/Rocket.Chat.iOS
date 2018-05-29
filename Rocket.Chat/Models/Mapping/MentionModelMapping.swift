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
        self.userId = values["_id"].string
        self.username = values["username"].stringValue
        if let realName = values["name"].string {
            self.realName = realName
        } else if let userId = userId {
            if let realm = realm {
                if let user = realm.object(ofType: User.self, forPrimaryKey: userId as AnyObject) {
                    self.realName = user.name ?? user.username ?? ""
                } else {
                    self.realName = values["username"].stringValue
                }
            }
        }
    }
}
