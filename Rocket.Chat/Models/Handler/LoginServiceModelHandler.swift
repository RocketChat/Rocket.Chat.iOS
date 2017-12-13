//
//  LoginServiceModelHandler.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension LoginService: ModelHandler {
    func add(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
        realm.add(self, update: true)
    }

    func update(_ values: JSON, realm: Realm) {
        map(values, realm: realm)
        realm.add(self, update: true)
    }

    func remove(_ values: JSON, realm: Realm) {
        realm.delete(self)
    }
}
