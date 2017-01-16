//
//  RealmExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

extension Realm {

    static func execute(_ completion: (Realm) -> Void) {
        guard let realm = try? Realm() else { return }
        try? realm.write {
            completion(realm)
        }
    }

    static func getOrCreate<T: BaseModel>(_ model: T.Type, primaryKey: String) -> T {
        var object: T!

        self.execute { (realm) in
            object = realm.object(ofType: model, forPrimaryKey: primaryKey as AnyObject)

            if object == nil {
                object = T()
            }
        }

        return object
    }

    // MARK: Mutate

    // This method will add or update a Realm's object.
    static func delete(_ object: Object) {
        guard !object.isInvalidated else { return }

        self.execute { realm in
            realm.delete(object)
        }
    }

    // This method will add or update a Realm's object.
    static func update(_ object: Object) {
        self.execute { realm in
            realm.add(object, update: true)
        }
    }

    // This method will add or update a list of some Realm's object.
    static func update<S: Sequence>(_ objects: S) where S.Iterator.Element: Object {
        self.execute { realm in
            realm.add(objects, update: true)
        }
    }

}
