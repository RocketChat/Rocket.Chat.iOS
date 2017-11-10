//
//  LoginServiceModelMapping.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension LoginService: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        self.service = values["service"].stringValue
        self.clientId = values["clientId"].stringValue
        self.custom = values["custom"].boolValue
        self.serverURL = values["serverURL"].stringValue
        self.tokenPath = values["tokenPath"].stringValue
        self.identityPath = values["identityPath"].stringValue
        self.authorizePath = values["authorizePath"].stringValue
        self.scope = values["scope"].stringValue
        self.buttonLabelText = values["buttonLabelText"].stringValue
        self.buttonLabelColor = values["buttonLabelColor"].stringValue
        self.tokenSentVia = values["tokenSentVia"].stringValue
        self.usernameField = values["usernameField"].stringValue
        self.mergeUsers = values["mergeUsers"].boolValue
        self.loginStyle = values["loginStyle"].string
        self.buttonColor = values["buttonColor"].string
    }
}
