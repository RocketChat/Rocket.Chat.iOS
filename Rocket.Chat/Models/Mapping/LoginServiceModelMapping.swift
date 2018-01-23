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
        service = values["service"].stringValue
        clientId = values["clientId"].string ?? values["appId"].string
        custom = values["custom"].boolValue
        serverUrl = values["serverURL"].stringValue
        tokenPath = values["tokenPath"].stringValue
        identityPath = values["identityPath"].stringValue
        authorizePath = values["authorizePath"].stringValue
        scope = values["scope"].stringValue
        buttonLabelText = values["buttonLabelText"].stringValue
        buttonLabelColor = values["buttonLabelColor"].stringValue
        tokenSentVia = values["tokenSentVia"].stringValue
        usernameField = values["usernameField"].stringValue
        mergeUsers = values["mergeUsers"].boolValue
        loginStyle = values["loginStyle"].string
        buttonColor = values["buttonColor"].string

        switch type {
        case .github: mapGitHub()
        case .facebook: mapFacebook()
        case .custom: break
        case .invalid: break
        }
    }

    func mapGitHub() {
        serverUrl = "https://github.com"
        tokenPath = "/login/oauth/access_token"
        identityPath = "https://api.github.com/user"
        authorizePath = "/login/oauth/authorize"
        buttonLabelText = "github"
        buttonLabelColor = "#ffffff"
        buttonColor = "#4c4c4c"
    }

    func mapFacebook() {
        serverUrl = "https://facebook.com"
        tokenPath = "/v2.8/oauth/access_token"
        identityPath = "https://graph.facebook.com/v2.8/me"
        authorizePath = "/v2.9/dialog/oauth"
        buttonLabelText = "facebook"
        buttonLabelColor = "#ffffff"
        buttonColor = "#4c4c4c"
    }
}
