//
//  User.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class User: BaseModel {
    dynamic var username: String?
    dynamic var name: String?
    var emails = List<Email>()
}
