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

class Message: BaseModel {
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
    
    override func update(dict: JSON) {
        self.identifier = dict["_id"].string!
        self.rid = dict["rid"].string!
        self.text = dict["msg"].string!
        
        if let createdAt = dict["ts"]["$date"].double {
            self.createdAt = NSDate.dateFromInterval(createdAt)
        }
        
        if let updatedAt = dict["_updatedAt"]["$date"].double {
            self.updatedAt = NSDate.dateFromInterval(updatedAt)
        }
        
        let user = User()
        user.identifier = dict["u"]["_id"].string!
        user.username = dict["u"]["username"].string
        
        Realm.execute { (realm) in
            realm.add(user, update: true)
        }
        
        self.user = user
    }
}