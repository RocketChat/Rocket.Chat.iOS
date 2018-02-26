//
//  User.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum UserPresence: String {
    case online, away
}

enum UserStatus: String {
    case offline, online, busy, away
}

class User: BaseModel {
    @objc dynamic var username: String?
    @objc dynamic var name: String?
    var emails = List<Email>()
    var roles = List<String>()

    @objc internal dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }

    var utcOffset: Double?
}

extension User {

    func hasPermission(_ permission: PermissionType, realm: Realm? = Realm.shared) -> Bool {
        guard let permissionRoles = PermissionManager.roles(for: permission, realm: realm) else { return false }

        for userRole in self.roles {
            for permissionRole in permissionRoles where userRole == permissionRole {
                return true
            }
        }

        return false
    }

    func displayName() -> String {
        guard let settings = AuthSettingsManager.settings else {
            return username ?? ""
        }

        if let name = name {
            if settings.useUserRealName && !name.isEmpty {
                return name
            }
        }

        return username ?? ""
    }

    func avatarURL(_ auth: Auth? = nil) -> URL? {
        guard
            !isInvalidated,
            let username = username,
            let auth = auth ?? AuthManager.isAuthenticated(),
            let baseURL = auth.baseURL(),
            let encodedUsername = username.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        else {
            return nil
        }

        return URL(string: "\(baseURL)/avatar/\(encodedUsername)")
    }

    func canViewAdminPanel(realm: Realm? = Realm.shared) -> Bool {
        return hasPermission(.viewPrivilegedSetting, realm: realm) ||
            hasPermission(.viewStatistics, realm: realm) ||
            hasPermission(.viewUserAdministration, realm: realm) ||
            hasPermission(.viewRoomAdministration, realm: realm)
    }

}

// MARK: Query
enum UserQueryParameter {
    case userId(String)
    case username(String)
}

extension User {
    static func find(username: String, realm: Realm? = Realm.shared) -> User? {
        guard
            let realm = realm,
            let user = realm.objects(User.self).filter("username = %@", username).first
        else {
            return nil
        }

        return user
    }

    static func fetch(by queryParameter: UserQueryParameter, realm: Realm? = Realm.shared, api: API? = API.current(), completion: @escaping (User?) -> Void) {
        guard
            let realm = realm,
            let api = api
        else {
            return
        }

        let request: UserInfoRequest
        switch queryParameter {
        case .userId(let userId):
            request = UserInfoRequest(userId: userId)
        case .username(let username):
            request = UserInfoRequest(username: username)
        }

        api.fetch(request, succeeded: {
            guard let user = $0.user else { return completion(nil) }

            realm.execute({ realm in
                let user = user
                realm.add(user, update: true)
            })

            completion(user)
        }, errored: { _ in
            completion(nil)
        })
    }
}
