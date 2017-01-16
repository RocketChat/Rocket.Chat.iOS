//
//  UserModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class UserModelHandler: BaseModelHandler {
    typealias Model = User

    static func add(_ object: User, values: JSON) {
        object.update(values)
    }

    static func update(_ object: User, values: JSON) {
        object.update(values)
    }

    static func remove(_ object: User, values: JSON) {
        Realm.execute({ (realm) in
            object.update(values)
            object.status = .offline
            realm.add(object, update: true)
        })
    }
}
