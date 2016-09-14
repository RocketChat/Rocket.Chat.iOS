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
    

    // MARK: ModelMapping
    
    override func update(dict: JSON) {
        if self.identifier == nil {
            self.identifier = dict["_id"].string!
        }

        self.rid = dict["rid"].string ?? ""
        self.text = dict["msg"].string ?? ""
        
        if let createdAt = dict["ts"]["$date"].double {
            self.createdAt = NSDate.dateFromInterval(createdAt)
        }
        
        if let updatedAt = dict["_updatedAt"]["$date"].double {
            self.updatedAt = NSDate.dateFromInterval(updatedAt)
        }
        
        if let userId = dict["u"]["_id"].string {
            self.user = Realm.getOrCreate(User.self, primaryKey: userId, values: dict["u"])
        }
    }
}