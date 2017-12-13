//
//  BaseModel.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class BaseModel: Object {
    @objc dynamic var identifier: String?

    override static func primaryKey() -> String? {
        return "identifier"
    }

    static func find(withIdentifier identifier: String) -> Self? {
        return Realm.shared?.objects(self).filter("identifier = '\(identifier)'").first
    }
}
