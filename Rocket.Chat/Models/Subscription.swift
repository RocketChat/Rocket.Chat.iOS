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

class Subscription: BaseModel {
    dynamic var auth: Auth?
    
    fileprivate dynamic var privateType = SubscriptionType.Channel.rawValue
    var type: SubscriptionType {
        get { return SubscriptionType(rawValue: privateType) ?? SubscriptionType.Group }
        set { privateType = newValue.rawValue }
    }
    
    dynamic var rid = ""

    dynamic var name = ""
    dynamic var unread = 0
    dynamic var open = false
    dynamic var alert = false
    dynamic var favorite = false

    dynamic var createdAt: Date?
    dynamic var lastSeen: Date?
    
    dynamic var otherUserId: String?
    var directMessageUser: User? {
        get {
            guard otherUserId != nil else { return nil }
            return try! Realm().objects(User.self).filter("identifier = '\(otherUserId!)'").first
        }
    }
    
    let messages = LinkingObjects(fromType: Message.self, property: "subscription")
    

    // MARK: ModelMapping
    
    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = dict["_id"].string!
        }

        self.rid = dict["rid"].string ?? ""
        self.name = dict["name"].string ?? ""
        self.unread = dict["unread"].int ?? 0
        self.open = dict["open"].bool ?? false
        self.alert = dict["alert"].bool ?? false
        self.favorite = dict["f"].bool ?? false
        self.privateType = dict["t"].string ?? SubscriptionType.Channel.rawValue
        
        if self.type == .DirectMessage {
            let userId = dict["u"]["_id"].string
            self.otherUserId = rid.replacingOccurrences(of: userId!, with: "")
        }
        
        if let createdAt = dict["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }
        
        if let lastSeen = dict["ls"]["$date"].double {
            self.lastSeen = Date.dateFromInterval(lastSeen)
        }
    }
}

extension Subscription {
    
    func fetchMessages() -> Results<Message> {
        return self.messages.sorted(byProperty: "createdAt", ascending: true)
    }
    
}
