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
    func add(_ values: JSON)
    func update(_ values: JSON)
    func remove(_ values: JSON)
}

extension ModelHandler where Self: BaseModel {
    static func handle(msg: ResponseMessage, primaryKey: String, values: JSON) {
        var object: Self!

        Realm.execute { (realm) in
            if let existentObject = realm.object(ofType: Self.self, forPrimaryKey: primaryKey as AnyObject) {
                object = existentObject
            }

            if object == nil {
                object = Self()
                object.setValue(primaryKey, forKey: Self.primaryKey() ?? "")
            }

            switch msg {
                case .added:
                    object.add(values)
                    break
                case .changed:
                    object.update(values)
                    break
                case .removed:
                    object.remove(values)
                    break
                default:
                    object.update(values)
                    break
            }
        }
    }
}
