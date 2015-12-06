//
//  Room.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 11/21/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class Room {
    
    var _id = String()
    var unread = Int()
    var t = String()
    var open = Bool()
    var ts = Double()
    var rid = String()
    var ls = Double()
    var alert = Bool()
    var name = String()
    
    
    init(_id: String ,unread: Int, t: String, open: Bool, ts: Double?, rid: String, ls: Double?, alert: Bool, name: String){
    
        self._id = _id
        self.unread = unread
        self.t = t
        self.open = open
        if ts != nil {
           self.ts = ts!
        }
        self.rid = rid
        if ls != nil {
            self.ls = ls!
        }
        self.alert = alert
        self.name = name
        
    }
    
    convenience init() {
        self.init(_id: String(), unread: Int(), t: String(), open: Bool(), ts: Double(), rid: String(), ls: Double(), alert: Bool(), name: String())
    }
    
    
}