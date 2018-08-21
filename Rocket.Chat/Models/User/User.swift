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

enum UserStatus: String, CustomStringConvertible {
    case offline, online, busy, away

    var description: String {
        switch self {
        case .online: return localized("status.online")
        case .offline: return localized("status.offline")
        case .busy: return localized("status.busy")
        case .away: return localized("status.away")
        }
    }
}

final class User: BaseModel {
    @objc dynamic var username: String?
    @objc dynamic var name: String?
    var emails = List<Email>()
    var roles = List<String>()

    @objc dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }

    @objc dynamic var utcOffset: Double = 0.0
}

extension User {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension User: UnmanagedConvertible {
    typealias UnmanagedType = UnmanagedUser
    var unmanaged: UnmanagedUser {
        return UnmanagedUser(self)
    }
}
