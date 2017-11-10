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
        self.service = values["service"].string ?? ""
        self.clientId = values["clientId"].string ?? ""
        self.custom = values["custom"].bool ?? false
        self.serverUrl = values["serverURL"].string ?? ""
        self.tokenPath = values["tokenPath"].string ?? ""
        self.identityPath = values["identityPath"].string ?? ""
        self.authorizePath = values["authorizePath"].string ?? ""
        self.scope = values["scope"].string ?? ""
        self.buttonLabelText = values["buttonLabelText"].string ?? ""
        self.buttonLabelColor = values["buttonLabelColor"].string ?? ""
        self.tokenSentVia = values["tokenSentVia"].string ?? ""
        self.usernameField = values["usernameField"].string ?? ""
        self.mergeUsers = values["mergeUsers"].bool ?? false
        self.loginStyle = values["loginStyle"].string
        self.buttonColor = values["buttonColor"].string
    }
}
