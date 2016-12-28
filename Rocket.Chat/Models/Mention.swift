//
//  Mention.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

class Mention: BaseModel {
    dynamic var objId = ""
    dynamic var username: String?
    dynamic var channel: String?
}
