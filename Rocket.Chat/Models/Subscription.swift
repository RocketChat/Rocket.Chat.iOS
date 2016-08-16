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

enum SubscriptionType: String {
    case DirectMessage = "d"
    case Channel = "c"
    case Group = "p"
}

class Subscription: BaseModel, ModelMapping {
    dynamic var auth: Auth?
    
    private dynamic var privateType = SubscriptionType.Channel.rawValue
    var type: SubscriptionType {
        get { return SubscriptionType(rawValue: privateType)! }
        set { privateType = newValue.rawValue }
    }
    
    dynamic var rid = ""

    dynamic var name = ""
    dynamic var unread = 0
    dynamic var open = false
    dynamic var alert = false
    dynamic var favorite = false

    dynamic var createdAt: NSDate?
    dynamic var lastSeen: NSDate?
    
    let messages = LinkingObjects(fromType: Message.self, property: "subscription")


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
        self.privateType = object["t"].string ?? SubscriptionType.Channel.rawValue
        
        if let createdAt = object["ts"]["$date"].double {
            self.createdAt = NSDate.dateFromInterval(createdAt)
        }
        
        if let lastSeen = object["ls"]["$date"].double {
            self.lastSeen = NSDate.dateFromInterval(lastSeen)
        }
    }
}


extension Subscription {
    
    func fetchMessages() -> Results<Message> {
        return self.messages.sorted("createdAt", ascending: true)
    }
    
}