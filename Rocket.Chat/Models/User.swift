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

enum UserStatus: String {
    case Offline = "offline"
    case Online = "online"
    case Busy = "busy"
    case Away = "away"
}

class User: BaseModel {
    dynamic var username: String?
    dynamic var name: String?
    var emails = List<Email>()

    private dynamic var privateStatus = UserStatus.Offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus)! }
        set { privateStatus = newValue.rawValue }
    }

    
    // MARK: ModelMapping
    
    override func update(dict: JSON) {
        if self.identifier == nil {
            self.identifier = identifier
        }
        
        if let username = dict["username"].string {
            self.username = username
        }
        
        if let status = dict["status"].string {
            self.status = UserStatus(rawValue: status) ?? .Offline
        }
    }
}
