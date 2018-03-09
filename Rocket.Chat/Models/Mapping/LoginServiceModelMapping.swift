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
        clientId = values["clientId"].string ?? values["appId"].string ?? values["consumerKey"].string
        consumerSecret = values["consumerSecret"].string
        requestTokenUrl = values["requestTokenUrl"].stringValue
        custom = values["custom"].boolValue
        serverUrl = values["serverURL"].stringValue
        tokenPath = values["tokenPath"].stringValue
        authorizePath = values["authorizePath"].stringValue
        scope = values["scope"].stringValue
        buttonLabelText = values["buttonLabelText"].stringValue
        buttonLabelColor = values["buttonLabelColor"].stringValue
        tokenSentVia = values["tokenSentVia"].stringValue
        usernameField = values["usernameField"].stringValue
        mergeUsers = values["mergeUsers"].boolValue
        loginStyle = values["loginStyle"].string
        buttonColor = values["buttonColor"].string

        // CAS
        loginUrl = values["login_url"].string

        // SAML
        entryPoint = values["entryPoint"].string
        issuer = values["issuer"].string
        provider = values["clientConfig"]["provider"].string

        switch type {
        case .facebook: mapFacebook()
        case .gitlab: mapGitLab()
        case .github: mapGitHub()
        case .linkedin: mapLinkedIn()
        case .twitter: mapTwitter()
        case .saml: break
        case .cas: break
        case .custom: break
        case .invalid: break
        }
    }

    func mapGitHub() {
        service = "github"
        scope = ""

        serverUrl = "https://github.com"
        tokenPath = "/login/oauth/access_token"
        authorizePath = "/login/oauth/authorize"
        buttonLabelText = "github"
        buttonLabelColor = "#ffffff"
        buttonColor = "#4c4c4c"
    }

    func mapGitLab() {
        service = "gitlab"
        scope = "read_user"

        serverUrl = "https://gitlab.com"
        tokenPath = "/oauth/token"
        authorizePath = "/oauth/authorize"
        buttonLabelText = "gitlab"
        buttonLabelColor = "#ffffff"
        buttonColor = "#373d47"

        callbackPath = "gitlab?close"
    }

    func mapFacebook() {
        service = "facebook"
        scope = ""

        serverUrl = "https://facebook.com"
        scope = "email"
        tokenPath = "https://graph.facebook.com/oauth/v2/accessToken"
        authorizePath = "/v2.9/dialog/oauth"
        buttonLabelText = "facebook"
        buttonLabelColor = "#ffffff"
        buttonColor = "#325c99"

        callbackPath = "facebook?close"
    }

    func mapLinkedIn() {
        service = "linkedin"
        scope = ""

        serverUrl = "https://linkedin.com"
        tokenPath = "/oauth/v2/accessToken"
        authorizePath = "/oauth/v2/authorization"
        buttonLabelText = "linkedin"
        buttonLabelColor = "#ffffff"
        buttonColor = "#1b86bc"

        callbackPath = "linkedin?close"
    }

    func mapCAS() {
        service = "cas"

        buttonLabelText = "CAS"
        buttonLabelColor = "#ffffff"
        buttonColor = "#13679a"
    }

    func mapTwitter() {
        service = "twitter"
        scope = ""

        serverUrl = "https://api.twitter.com"
        requestTokenUrl = "/oauth/request_token"
        tokenPath = "/oauth/access_token"
        authorizePath = "/oauth/authorize"
        buttonLabelText = "twitter"
        buttonLabelColor = "#ffffff"
        buttonColor = "#00aced"
        callbackPath = "twitter?close"
    }
}
