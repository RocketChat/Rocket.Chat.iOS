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
    
}
