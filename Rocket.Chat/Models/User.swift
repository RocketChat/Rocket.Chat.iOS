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

    @objc fileprivate dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }

    var utcOffset: Double?
}

extension User {

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

}
