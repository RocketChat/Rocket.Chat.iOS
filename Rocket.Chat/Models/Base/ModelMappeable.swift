//
//  ModelMappeable.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import Realm

public typealias UpdateBlock<T> = (_ object: T?) -> Void

protocol ModelMappeable {
    func map(_ values: JSON)
}

extension ModelMappeable where Self: BaseModel {
    @discardableResult static func getOrCreate(values: JSON, updates: UpdateBlock<Self>?) -> Self {
        var object: Self!

        Realm.execute { (_) in
            if let primaryKey = values["_id"].string {
                if let newObject = try? Realm().object(ofType: Self.self, forPrimaryKey: primaryKey as AnyObject) {
                    object = newObject
                }
            }

            if object == nil {
                object = Self()
            }

            object.map(values)
            updates?(object)
        }

        return object
    }
}
