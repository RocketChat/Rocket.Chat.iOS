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
    
    static func execute(completion: (Realm) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            completion(realm)
        }
    }
    
    static func getOrCreate<T: BaseModel>(model: T.Type, primaryKey: String, values: JSON) -> T {
        var object: T!

        self.execute { (realm) in
            object = realm.objectForPrimaryKey(model, key: primaryKey)
            
            if object == nil {
                object = T()
            }

            object.update(values)
        }
        
        return object
    }
    

    // MARK: Mutate
    
    // This method will add or update a Realm's object.
    static func update(object: Object) {
        self.execute() { (realm) in
            realm.add(object, update: true)
        }
    }
    
    // This method will add or update a list of some Realm's object.
    static func update<S: SequenceType where S.Generator.Element: Object>(objects: S) {
        self.execute() { (realm) in
            realm.add(objects, update: true)
        }
    }
    
}
