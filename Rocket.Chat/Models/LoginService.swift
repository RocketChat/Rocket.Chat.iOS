//
//  LoginService.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

enum LoginServiceType {
    case github
    case facebook
    case linkedin
    case saml
    case cas
    case custom
    case invalid

    init(string: String) {
        switch string {
        case "github": self = .github
        case "facebook": self = .facebook
        case "linkedin": self = .linkedin
        case "saml": self = .saml
        case "cas": self = .cas
        default: self = .invalid
        }
    }
}

class LoginService: BaseModel {
    @objc dynamic var service: String?
    @objc dynamic var clientId: String?
    @objc dynamic var custom = false
    @objc dynamic var serverUrl: String?
    @objc dynamic var tokenPath: String?
    @objc dynamic var identityPath: String?
    @objc dynamic var authorizePath: String?
    @objc dynamic var scope: String?
    @objc dynamic var buttonLabelText: String?
    @objc dynamic var buttonLabelColor: String?
    @objc dynamic var tokenSentVia: String?
    @objc dynamic var usernameField: String?
    @objc dynamic var mergeUsers = false
    @objc dynamic var loginStyle: String?
    @objc dynamic var buttonColor: String?

    // CAS

    @objc dynamic var loginUrl: String?

    // true if LoginService has enough information to be used
    var isValid: Bool {
        if type == .cas && loginUrl != nil {
            return true
        }

        return !(serverUrl?.isEmpty ?? true)
    }

    var type: LoginServiceType {
        if custom == true {
            return .custom
        }

        if let service = service {
            return LoginServiceType(string: service)
        }

        return .invalid
    }

    @objc dynamic var responseType: String?
    @objc dynamic var callbackPath: String?
}

// MARK: OAuth helper extensions

extension LoginService {
    var authorizeUrl: String? {
        guard
            let serverUrl = serverUrl,
            let authorizePath = authorizePath
        else {
            return nil
        }

        return "\(serverUrl)\(authorizePath)"
    }

    var accessTokenUrl: String? {
        guard
            let serverUrl = serverUrl,
            let tokenPath = tokenPath
            else {
                return nil
        }

        return tokenPath.contains("://") ? tokenPath : "\(serverUrl)\(tokenPath)"
    }
}

// MARK: Realm extensions

extension LoginService {
    static func find(service: String, realm: Realm) -> LoginService? {
        var object: LoginService?

        if let findObject = realm.objects(LoginService.self).filter("service == '\(service)'").first {
            object = findObject
        }

        return object
    }
}

// MARK: Standard Login Services extensions

extension LoginService {
    static var facebook: LoginService {
        let service = LoginService()
        service.mapFacebook()
        return service
    }

    static var github: LoginService {
        let service = LoginService()
        service.mapGitHub()
        return service
    }

    static var linkedin: LoginService {
        let service = LoginService()
        service.mapLinkedIn()
        return service
    }

    static var cas: LoginService {
        let service = LoginService()
        service.mapCAS()
        return service
    }
}
