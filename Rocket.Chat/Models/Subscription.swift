//
//  Subscription.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

class Subscription: BaseModel {
    dynamic var rid = ""
    dynamic var name = ""
    dynamic var unread = 0
    dynamic var open = false
    dynamic var alert = false
}