//
//  Message.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class Mention: BaseModel {
    dynamic var objId = ""
    dynamic var username: String?
    dynamic var channel: String?
}

class Message: BaseModel {
    dynamic var rid = ""
    dynamic var createdAt: NSDate?
    dynamic var updatedAt: NSDate?
    dynamic var user: User?
    
    dynamic var text = ""

    var mentions = List<Mention>()
}