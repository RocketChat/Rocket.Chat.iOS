//
//  User.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class Email: BaseModel {
    dynamic var email = ""
    dynamic var verified = false
}

class User: BaseModel {
    dynamic var username = ""
    dynamic var name = ""
    let emails = List<Email>()
}
