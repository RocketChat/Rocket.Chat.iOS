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

/// A data structure represents a user
public class User: BaseModel {
    /// A unique login name of the user
    public dynamic var username: String?
    /// A representitive name of the user
    public dynamic var name: String?
    /// A user can link multiple email address to his/her/their account
    public var emails = List<Email>()

    fileprivate dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }
}

extension User {

    func displayName() -> String {
        guard let settings = DependencyRepository.authSettingsManager.settings else {
            return username ?? ""
        }

        return (settings.useUserRealName ? name : username) ?? ""
    }

}
