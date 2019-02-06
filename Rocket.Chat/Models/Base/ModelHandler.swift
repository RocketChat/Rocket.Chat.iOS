//
//  ModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

protocol ModelHandler {
    func add(_ values: JSON, realm: Realm)
    func update(_ values: JSON, realm: Realm)
    func remove(_ values: JSON, realm: Realm)
}

extension ModelHandler where Self: BaseModel {
    static func handle(msg: ResponseMessage, primaryKey: String, values: JSON) {
        Realm.execute({ (realm) in
            var object: Self!

            if let existentObject = realm.object(ofType: Self.self, forPrimaryKey: primaryKey as AnyObject) {
                object = existentObject
            }

            if object == nil {
                object = Self()
                object.setValue(primaryKey, forKey: Self.primaryKey() ?? "")
            }

            switch msg {
            case .added, .inserted:
                object.add(values, realm: realm)
            case .changed:
                object.update(values, realm: realm)
            case .removed:
                object.remove(values, realm: realm)
            default:
                object.update(values, realm: realm)
            }
        })
    }
}
