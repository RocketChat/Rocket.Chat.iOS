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

public enum UserPresence: String {
    case online, away
}

public enum UserStatus: String {
    case offline, online, busy, away
}

public class User: BaseModel {
    dynamic var username: String?
    dynamic var name: String?
    var emails = List<Email>()

    fileprivate dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }
}
