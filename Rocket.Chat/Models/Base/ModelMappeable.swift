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

protocol ModelMappeable {
    func map(_ values: JSON)
}

extension ModelMappeable where Self: BaseModel {
    static func getOrCreate(values: JSON) -> Self {
        var object: Self!

        Realm.execute { (realm) in
            if let primaryKey = values["_id"].string {
                object = realm.object(ofType: Self.self, forPrimaryKey: primaryKey as AnyObject)
            }

            if object == nil {
                object = Self()
            }

            object.map(values)
        }

        return object
    }
}
