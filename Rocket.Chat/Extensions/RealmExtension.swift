//
//  RealmExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    static func execute(completion: (Realm) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            completion(realm)
        }
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
