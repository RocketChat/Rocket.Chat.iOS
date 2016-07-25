//
//  Subscription.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Subscription: BaseModel, ModelMapping {
    dynamic var auth: Auth?
    
    dynamic var rid = ""

    dynamic var name = ""
    dynamic var unread = 0
    dynamic var open = false
    dynamic var alert = false
    dynamic var favorite = false

    dynamic var createdAt: NSDate?
    dynamic var lastSeen: NSDate?


    // MARK: ModelMapping

    convenience required init(object: JSON) {
        self.init()

        self.identifier = object["_id"].string!
        self.rid = object["rid"].string!
        self.name = object["name"].string!
        self.unread = object["unread"].int ?? 0
        self.open = object["open"].bool ?? false
        self.alert = object["alert"].bool ?? false
        self.favorite = object["f"].bool ?? false
        
        if let createdAt = object["ts"]["$date"].double {
            self.createdAt = NSDate.dateFromInterval(createdAt)
        }
        
        if let lastSeen = object["ls"]["$date"].double {
            self.lastSeen = NSDate.dateFromInterval(lastSeen)
        }
    }
}