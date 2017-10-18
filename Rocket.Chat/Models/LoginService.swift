//
//  LoginService.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class LoginService: BaseModel {
    @objc dynamic var service: String?
    @objc dynamic var clientId: String?
    @objc dynamic var custom = false
    @objc dynamic var serverURL: String?
    @objc dynamic var tokenPath: String?
    @objc dynamic var identityPath: String?
    @objc dynamic var authorizePath: String?
    @objc dynamic var scope: String?
    @objc dynamic var buttonLabelText: String?
    @objc dynamic var buttonLabelColor: String?
    @objc dynamic var tokenSentVia: String?
    @objc dynamic var usernameField: String?
    @objc dynamic var mergeUsers = false
}

extension LoginService {
    static func find(service: String) -> LoginService? {
        var object: LoginService?

        if let findObject = Realm.shared?.objects(LoginService.self).filter("service == '\(service)'").first {
            object = findObject
        }

        return object
    }
}
