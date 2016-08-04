//
//  Message.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Message: BaseModel, ModelMapping {
    dynamic var subscription: Subscription!
    
    dynamic var rid = ""
    dynamic var createdAt: NSDate?
    dynamic var updatedAt: NSDate?
    dynamic var user: User?
    
    dynamic var text = ""

    var mentions = List<Mention>()

    func userAvatarURL() -> NSURL? {
        guard let username = user?.username else { return nil }
        guard let serverURL = NSURL(string: subscription.auth!.serverURL) else { return nil }
        return NSURL(string: "http://\(serverURL.host!)/avatar/\(username).jpg")!
    }
    

    // MARK: ModelMapping

    convenience required init(object: JSON) {
        self.init()

        self.identifier = object["_id"].string!
        self.rid = object["rid"].string!
        self.text = object["msg"].string!
        
        if let createdAt = object["ts"]["$date"].double {
            self.createdAt = NSDate.dateFromInterval(createdAt)
        }
        
        if let updatedAt = object["_updatedAt"]["$date"].double {
            self.updatedAt = NSDate.dateFromInterval(updatedAt)
        }
        
        let user = User()
        user.identifier = object["u"]["_id"].string!
        user.username = object["u"]["username"].string
        
        Realm.execute { (realm) in
            realm.add(user, update: true)
        }
        
        self.user = user
    }
}