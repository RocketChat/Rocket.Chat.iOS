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
        return Realm.current?.objects(self).filter("identifier = '\(identifier)'").first
    }

    @discardableResult
    static func delete(withIdentifier identifier: String) -> Bool {
        guard
            let realm = Realm.current,
            let object = realm.objects(self).filter("identifier = '\(identifier)'").first
        else {
            return false
        }

        realm.delete(object)

        return true
    }
}
